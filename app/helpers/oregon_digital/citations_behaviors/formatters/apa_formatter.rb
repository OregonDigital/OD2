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
          text += authors_text_for(work)
          text += pub_date_text_for(work)
          text += add_title_text_for(work)
          text += add_publisher_text_for(work)
          text.html_safe
        end
      end
    end
  end
end
