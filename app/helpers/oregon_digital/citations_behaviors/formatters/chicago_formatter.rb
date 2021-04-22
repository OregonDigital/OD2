# frozen_string_literal:true

module OregonDigital
  module CitationsBehaviors
    module Formatters
      # MLA Citation Formatter
      class ChicagoFormatter < Hyrax::CitationsBehaviors::Formatters::ChicagoFormatter
        include OregonDigital::CitationsBehaviors::NameBehavior
        include OregonDigital::CitationsBehaviors::PublicationBehavior
        include Hyrax::CitationsBehaviors::TitleBehavior

        def format(work)
          text = super(work)
          # setup formatted author list
          text += " #{view_context.controller.request.original_url.split('?').first if view_context.respond_to?(:controller)}"
          text.html_safe
        end
      end
    end
  end
end
