# frozen_string_literal:true

module OregonDigital
  module CitationsBehaviors
    module Formatters
      # MLA Citation Formatter
      class ApaFormatter < Hyrax::CitationsBehaviors::Formatters::ApaFormatter
        include OregonDigital::CitationsBehaviors::NameBehavior
        include OregonDigital::CitationsBehaviors::PublicationBehavior
        include Hyrax::CitationsBehaviors::TitleBehavior

        # rubocop:disable Metrics/AbcSize
        def format(work)
          text = ''
          # Collection the work is a part of.
          collection = ActiveFedora::Base.find(work.member_of_collection_ids.first) unless work.member_of_collection_ids.empty?
          text += "#{collection.title.first}, " unless collection.nil?

          # Institution the work is a part of.
          institution = OregonDigital::InstitutionPicker.institution_full_name(work)
          text += "#{institution}." unless institution.blank?

          # Published Date
          pub_date = setup_pub_date(work)
          text += " (#{whitewash(pub_date)}). " unless pub_date.nil?

          # Title
          text += format_title(work.to_s)
          text += "Retrieved from #{view_context.controller.request.original_url.split('?').first if view_context.respond_to?(:controller)}"

          text.html_safe
        end
        # rubocop:enable Metrics/AbcSize

        private

        def whitewash(text)
          Loofah.fragment(text.to_s).scrub!(:whitewash).to_s
        end
      end
    end
  end
end
