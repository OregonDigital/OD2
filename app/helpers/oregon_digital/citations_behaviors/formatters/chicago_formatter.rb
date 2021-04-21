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
          text = ''

          # setup formatted author list
          authors_list = chicago_author_list(work)
          text += format_authors(authors_list)
          text = "<span class=\"citation-author\">#{text}</span>" if text.present?

          text += format_title(work.to_s)
          # Get Pub Date
          pub_date = setup_pub_date(work)
          text += " #{whitewash(pub_date)}." unless pub_date.nil?

          
          pub_info = setup_pub_info(work, false)
          text += " #{whitewash(pub_info)}." if pub_info.present?
          text += " #{view_context.controller.request.original_url.split('?').first if view_context.respond_to?(:controller)}"
          text.html_safe
        end

        private

        def chicago_author_list(work)
          work.author_label
        end
      end
    end
  end
end
