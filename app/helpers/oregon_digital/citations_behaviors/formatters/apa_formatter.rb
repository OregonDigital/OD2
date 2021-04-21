# frozen_string_literal:true

module OregonDigital
  module CitationsBehaviors
    module Formatters
      # MLA Citation Formatter
      class ApaFormatter < Hyrax::CitationsBehaviors::Formatters::ApaFormatter
        include OregonDigital::CitationsBehaviors::NameBehavior
        include OregonDigital::CitationsBehaviors::PublicationBehavior
        include Hyrax::CitationsBehaviors::TitleBehavior

        def format(work)
          text = ''
          # set authors
          authors_list = chicago_author_list(work)
          text += format_authors(authors_list)
          text = "<span class=\"citation-author\">#{text}</span>" if text.present?
          # set publish or access date
          pub_date = setup_pub_date(work)
          text += " #{whitewash(pub_date)}." unless pub_date.nil?
          # set title
          text += format_title(work.to_s)
          # set rest of publisher info and uri
          pub_info = setup_pub_info(work, false)
          text += " #{whitewash(pub_info)}." if pub_info.present?
          text += " #{view_context.controller.request.original_url.split('?').first if view_context.respond_to?(:controller)}"
          text.html_safe
        end

        private

        def chicago_author_list(work)
          work.author_label
        end

        def whitewash(text)
          Loofah.fragment(text.to_s).scrub!(:whitewash).to_s
        end
      end
    end
  end
end
