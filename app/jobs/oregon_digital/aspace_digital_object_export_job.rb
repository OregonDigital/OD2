# frozen_string_literal: true

module OregonDigital
  # job to enable the export of items for a given importer as
  # digital objects formatted for ArchivesSpace
  class AspaceDigitalObjectExportJob < OregonDigital::ApplicationJob
    queue_as :default

    def perform(args)
      OregonDigital::AspaceDigitalObjectExportService.new(args).run
    end
  end
end
