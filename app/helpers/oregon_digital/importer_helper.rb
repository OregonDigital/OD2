# frozen_string_literal: true

module OregonDigital
  # helpers for use with custom behavior in the Importer
  module ImporterHelper
    def importers_list_all
      Bulkrax::Importer.order(created_at: :desc).page params[:page]
    end

    def list_headers
      ['Name', 'Date created', 'User', 'Status']
    end

    def list_fields
      %i[created_at user status]
    end
  end
end
