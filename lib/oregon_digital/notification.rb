# frozen_string_literal: true

module OregonDigital
  # object/methods for use in daily email rake task
  class Notification
    def user_map
      @user_map ||= {}
    end

    def structure
      { reviews: [], changes: [] }
    end

    def add_change_items
      span = 86_400 # seconds
      fields = 'id,depositor_ssim'
      change_items = fetch_items('changes_required', fields, span)
      change_items.each do |item|
        (user_map[item['depositor_ssim'].first] ||= structure)[:changes].push item['id']
      end
    end

    # rubocop:disable Style/IfUnlessModifier
    def add_review_items
      span = 172_800 # seconds
      fields = 'id,depositor_ssim,thumbnail_path_ss,has_model_ssim'
      review_items = fetch_items('pending_review', fields, span)
      review_items.each do |item|
        if (item['has_model_ssim'].first == 'Generic') || simple_derivative_check(item)
          (user_map[item['depositor_ssim'].first] ||= structure)[:reviews].push item['id']
        end
      end
    end
    # rubocop:enable Style/IfUnlessModifier

    # expects a structure (see above)
    def build_message(data)
      keywords = []
      data.keys.each do |k|
        keywords << "#{k}: #{data[k].size}" unless data[k].blank?
      end
      keywords.join(', ')
    end

    # workflow = pending_review or changes_required
    def fetch_items(workflow, fields, span)
      t = get_time_window(span)
      items = Hyrax::SolrService.query("system_create_dtsi:[#{t[0]} TO #{t[1]}] AND  workflow_state_name_ssim:#{workflow}", fl: fields, rows: 10_000)
      items
    end

    def simple_derivative_check(item)
      !item['thumbnail_path_ss'].blank? && (item['thumbnail_path_ss'].include? 'downloads')
    end

    # span is in seconds, eg 86400, 172800
    def get_time_window(span)
      t = Time.new.utc
      t_back = t - span
      format = '%Y-%m-%dT%H:%M:%SZ'
      t_str = t.strftime(format)
      t_back_str = t_back.strftime(format)
      [t_back_str, t_str]
    end
  end
end
