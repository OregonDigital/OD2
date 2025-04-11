# frozen_string_literal: true

module OregonDigital
  # Methods for verification
  class VerificationReporter
    attr_accessor :work_ids

    def initialize(id, time)
      @batch_id = id
      @time = time
    end

    # consider adding a work_ids method for reading pids from a file
    # and GUI to launch service

    def compile_errors
      errors = []
      work_ids.each do |pid|
        errors << { pid => retrieve_errors(pid) }
      end
      errors
    end

    def retrieve_errors(pid)
      work = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: pid)
      work.all_errors
    rescue Valkyrie::Persistence::ObjectNotFoundError
      { valkyrie: ['Unable to load work.'] }
    end

    def build_report_hash
      { 'title' => "Report for Batch #{@batch_id}", 'works' => compile_errors }
    end

    def write_report
      f = File.open(file_path, 'w')
      f.puts JSON.dump(build_report_hash)
      f.close
    end

    def file_path
      File.join(OD2::Application.config.local_path, "verify/batch_#{@batch_id}_report_#{@time}.json")
    end
  end
end
