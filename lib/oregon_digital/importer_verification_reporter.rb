# frozen_string_literal: true

module OregonDigital
  # Modifies VerificationReporter for use with Bulkrax::Importer
  class ImporterVerificationReporter < VerificationReporter
    # returns an array of hashes, eg { work_id: 'abcde1234', entry_identifier: '80-101' }
    # if solr returns an empty array, the work_id will be nil
    def work_ids
      ids = []
      Bulkrax::Importer.find(@batch_id).entries.pluck(:identifier).each do |i|
        id = Hyrax::SolrService.query("bulkrax_identifier_sim:#{i}", fl: 'id', rows: 1).map { |x| x['id'] }.first
        ids << { work_id: id, entry_identifier: i }
      end
      ids
    end

    def compile_errors
      errors = []
      work_ids.each do |item|
        errors << if item[:work_id].nil?
                    { item[:entry_identifier] => { solr: ['Unable to load work for this entry.'] } }
                  else
                    { item[:work_id] => retrieve_errors(item[:work_id]) }
                  end
      end
      errors
    end

    def display_path
      URI.join(Rails.application.routes.url_helpers.root_url, "importers/#{@batch_id}/show_errors?time=#{@time}").to_s
    end

    def notify_user(user_mail)
      message = 'Your verification results are available at ' + display_path
      OregonDigital::NotificationMailer.with(email: user_mail, message: message).notification_email.deliver_now
    end
  end
end
