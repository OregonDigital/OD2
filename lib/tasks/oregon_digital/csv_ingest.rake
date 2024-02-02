# frozen_string_literal:true

# what does the csv look like?
#  fields in the top line
#  what about multiple values? pipe as a delimiter
#  worktype in the first col, eg generic, image ...
#  filenames in the second col
#  id in the third col, omit "oregondigital:"
#  if read_groups is included, this will override the default of public
#  if admin_set_id is included, it will override admin_set/default
# args: path to dir containing all files including csv, name of the csv, email
# called like this: rake oregon_digital:csv_ingest csv=mymetadata.csv filedir=/data/allthefiles email=admin@example.org

WORKTYPE = 0
FILENAMES = 1
ID = 2
SKIPTO = 3

namespace :oregon_digital do
  desc 'ingest works using csv'
  task csv_ingest: :environment do
    csv = ENV['csv']
    filedir = ENV['filedir']
    email = ENV['email']
    process(csv, filedir, email)
  end
end

def process(csv, filedir, email)
  user = User.find_by_user_key(email)
  logger = create_logger
  csv = File.open("#{filedir}/#{csv}")
  fields = csv.readline.split("\t")
  csv.readlines.each do |line|
    work = process_line(line, fields, email, logger)
    work.read_groups = ['public'] if work.read_groups.empty?
    work_with_set = associate_admin_set(work)
    uploaded_files = prep_files(line, filedir, user, logger)
    if !uploaded_files.empty?
      Hyrax::AttachFilesToWorkJob.perform_later(work_with_set, uploaded_files)
      logger.info "saved item #{work.id} and queued AttachFilesToWorkJob"
    else
      logger.error "Did not attach files to #{work.id}"
    end
  end
  csv.close
end

def process_line(line, fields, email, logger)
  vals = line.split("\t")
  work = vals[WORKTYPE].humanize.constantize.new
  work.id = vals[ID]
  numfields = fields.length
  (SKIPTO..numfields - 1).each do |i|
    vals[i].split('|').each do |v|
      work.send(fields[i].strip.to_sym) << v.strip
    rescue StandardError => e
      logger.error(e.message)
    end
  end
  work.depositor = email
  work.save
  # Enable once all model objects are fully valkyrized and indexing works again
  # Hyrax.persister.save(resource: work)
  # Hyrax.index_adapter.save(resource: work)
  work
end

def prep_files(line, filedir, user, logger)
  files = line.split("\t")[FILENAMES].split('|')
  uploaded_files = []
  files.each do |file|
    f = Hyrax::UploadedFile.new(user: user, file: File.open("#{filedir}/#{file}"))
    f.save
    uploaded_files += [f]
  end
  uploaded_files
rescue StandardError => e
  logger.error(e.message)
  []
end

def create_logger
  datetime_today = Time.now.strftime('%Y%m%d%H%M%S') # "20171021125903"
  ActiveSupport::Logger.new("#{Rails.root}/log/csv_ingest_job-#{datetime_today}.log")
end

def associate_admin_set(work)
  if work.admin_set_id.blank?
    id = 'admin_set/default'
    work.admin_set_id = [id]
    work.save
    # Hyrax.persister.save(resource: work)
    # Hyrax.index_adapter.save(resource: work)
  else
    id = work.admin_set_id
  end
  admin_set = AdminSet.find(id)
  admin_set.members += [work]
  work
end
