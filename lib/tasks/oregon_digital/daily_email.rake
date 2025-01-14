# frozen_string_literal: true

namespace :oregon_digital do
  desc 'Send out daily email to users based on if changes/review is required'
  task daily_email: :environment do

    # process the items for specific workflows
    add_review_items
    add_change_items

    # email users
    user_map.each do |user|
      message = build_message(user)
      OregonDigital::NotificationMailer.with(email: user, message: message).deliver_now
    end
  end
end

def user_map
  @user_map ||= {}
end

def structure
  { review: [], changes: [] }
end

def add_change_items
  fields = 'id,depositor_ssim'
  change_items = fetch_items("changes_required", fields, 86400)
  change_items.each do |item|
    (user_map[item['depositor_ssim'].first] ||= structure)[:changes].push item['id']
  end
end

def add_review_items
  fields = 'id,depositor_ssim,thumbnail_path_ss,has_model_ssim'
  review_items = fetch_items("review_pending", fields, 172800)
  review_items.each do |item|
    if item['has_model_ssim'].first == 'Generic' || simple_derivative_check(item)
      (user_map[item['depositor_ssim'].first] ||= structure)[:reviews].push item['id']
    end
  end
end

def build_message(user)
  keywords = []
  structure.keys.each do |k|
    keywords << "#{k}: user[k].size" unless user[k].blank?
  end
  keywords.join(", ")
end

# workflow = review_pending or changes_required
def fetch_items(workflow, fields, span)
  t = get_time_window(span)
  Hyrax::SolrService.query("system_create_dtsi:[#{t[0]} TO #{t[1]}] AND workflow_state_name_ssim:#{workflow}", fl: fields, rows: 10000)
end


def simple_derivative_check(item)
  ((!item['thumbnail_path_ss'].blank?) && (item['thumbnail_path_ss'].include? "downloads"))
end

# span is in seconds, eg 86400, 172800
def get_time_window(span)
  t = Time.new.utc
  t_back = t-span
  format = "%Y-%m-%dT%H:%M:%SZ"
  t_str = t.strftime(format)
  t_back_str = t_back.strftime(format)
  [t_back_str, t_str]
end
