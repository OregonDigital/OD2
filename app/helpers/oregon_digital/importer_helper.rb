# frozen_string_literal: true

module OregonDigital
  # helpers for use with custom behavior in the Importer
  module ImporterHelper
    def importers_list_all
      Bulkrax::Importer.order(created_at: :desc).all.map { |i| [i.name, i.id, i.created_at] }
    end
  end
end
