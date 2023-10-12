# frozen_string_literal:true

module OregonDigital
  module CitationsBehaviors
    module Formatters
      # MLA Citation Formatter
      class ChicagoFormatter < Hyrax::CitationsBehaviors::Formatters::ChicagoFormatter
        include OregonDigital::CitationsBehaviors::NameBehavior
        include OregonDigital::CitationsBehaviors::PublicationBehavior
        include Hyrax::CitationsBehaviors::TitleBehavior

        # rubocop:disable Metrics/AbcSize
        # rubocop:disable Metrics/MethodLength
        def format(work)
          text = ''
          # Collection the work is a part of.
          collection = ActiveFedora::Base.find(work.member_of_collection_ids.first) unless work.member_of_collection_ids.empty?
          text += "#{collection.title.first}, " unless collection.nil?

          # Institution the work is a part of.
          institution = OregonDigital::InstitutionPicker.institution_full_name(work)
          text += "#{institution}. " unless institution.blank?

          # Title
          text += "\"#{work}\""

          text += ' Oregon Digital. '

          # Published Date
          pub_date = Date.today
          text += " Accessed #{whitewash(pub_date)}." unless pub_date.nil?

          text += " #{view_context.controller.request.original_url.split('?').first if view_context.respond_to?(:controller)}"

          text.html_safe
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/MethodLength

        private

        def whitewash(text)
          Loofah.fragment(text.to_s).scrub!(:whitewash).to_s
        end
      end
    end
  end
end
