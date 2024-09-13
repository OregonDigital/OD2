# frozen_string_literal: true

module OregonDigital
  # The job responsible for exporting collection members as rdf
  class ExportCollectionMembersJob < OregonDigital::ApplicationJob
    queue_as :default

    def perform(args)
      OregonDigital::ExportCollectionMembersService.new(args).run
    end
  end
end
