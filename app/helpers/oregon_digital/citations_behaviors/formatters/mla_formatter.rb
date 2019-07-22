# frozen_string_literal:true

module OregonDigital
  module CitationsBehaviors
    module Formatters
      class MlaFormatter < Hyrax::CitationsBehaviors::Formatters::MlaFormatter
        include OregonDigital::CitationsBehaviors::NameBehavior
        include OregonDigital::CitationsBehaviors::PublicationBehavior
        include Hyrax::CitationsBehaviors::TitleBehavior

        def format(work)
          text = super
          text << " " + persistent_url(work)
          text.html_safe
        end
      end
    end
  end
end
