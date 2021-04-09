# frozen_string_literal:true

module OregonDigital
  module CitationsBehaviors
    module Formatters
      # MLA Citation Formatter
      class WikiFormatter < Hyrax::CitationsBehaviors::Formatters::MlaFormatter
        include OregonDigital::CitationsBehaviors::NameBehavior
        include OregonDigital::CitationsBehaviors::PublicationBehavior
        include Hyrax::CitationsBehaviors::TitleBehavior

        def format(work)
          text = super
          text << "<ref name=Oregon Digital>{{cite web | url= #{view_context.controller.request.original_url.split('?').first if view_context.respond_to?(:controller)}| title= #{work.title.first} |author=#{work.author.first} |accessdate=#{Date.today} |publisher=#{work.publisher.first.to_s}}}</ref>"
          text.html_safe
        end
      end
    end
  end
end
