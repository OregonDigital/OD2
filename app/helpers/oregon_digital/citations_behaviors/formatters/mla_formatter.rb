# frozen_string_literal:true

module OregonDigital
  module CitationsBehaviors
    module Formatters
      # MLA Citation Formatter
      class MlaFormatter < Hyrax::CitationsBehaviors::Formatters::MlaFormatter
        include OregonDigital::CitationsBehaviors::NameBehavior
        include OregonDigital::CitationsBehaviors::PublicationBehavior
        include Hyrax::CitationsBehaviors::TitleBehavior

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        def format(work)
          text = ''
          # set authors
          authors_list = all_authors(work)
          text += format_authors(authors_list)
          text = "<span class=\"citation-author\">#{text}</span>" if text.present?
          # set title
          text += format_title(work.to_s)
          # set rest of publisher info
          pub_info = setup_pub_info(work, false)
          text += " #{whitewash(pub_info)}." if pub_info.present?
          # set publish or access date and uri
          pub_date = setup_pub_date(work)
          text += " #{whitewash(pub_date)}." unless pub_date.nil?
          text += " #{view_context.controller.request.original_url.split('?').first if view_context.respond_to?(:controller)}"
          text.html_safe
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength
        
      end
    end
  end
end
