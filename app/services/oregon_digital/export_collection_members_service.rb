# frozen_string_literal: true

module OregonDigital
  # service to perform export of collection members as RDF
  class ExportCollectionMembersService
    def initialize(args)
      @coll_id = args[:coll_id]
      @email = args[:email]
      FileUtils.rm(zip_path, force: true)
    end

    def run
      start = count = 0
      Zip::File.open(zip_path, create: true) do |zip_file|
        while start < total
          output = "#{@coll_id}_#{count}.nt"
          write_file(zip_file, output, start)
          start += max
          count += 1
        end
      end
      ExportMailer.with(email: @email, url: download_url, subject: mail_subject).export_ready.deliver_later
    end

    def write_file(zip_file, output, start)
      zip_file.get_output_stream(output) do |f|
        pids(start).each do |pid|
          path = [fcrepo_url, bucketize(pid), pid].join('/')
          data = `curl -H "Accept: application/n-triples" "#{path}"`
          f.write data if data.start_with? '<' + path
        end
      end
    end

    def mail_subject
      "members of #{@coll_id}"
    end

    def download_url
      URI.join(Rails.application.routes.url_helpers.root_url, Rails.application.routes.url_helpers.download_members_collection_path(@coll_id)).to_s
    end

    def max
      50_000
    end

    def fcrepo_url
      ActiveFedora.fedora.base_uri
    end

    def pids(start)
      Hyrax::SolrService.query("member_of_collection_ids_ssim:#{@coll_id}", fl: 'id', rows: max, start: start).map { |x| x['id'] }
    end

    def total
      @total ||= Hyrax::SolrService.count("member_of_collection_ids_ssim:#{@coll_id}")
    end

    def bucketize(pid)
      pid.gsub(/(.{2})/, '\1/')[0, 11]
    end

    def zip_path
      File.join(OD2::Application.config.local_path, 'export_colls', "export_#{@coll_id}.zip")
    end
  end
end
