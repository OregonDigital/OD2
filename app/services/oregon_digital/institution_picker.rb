# frozen_string_literal: true

module OregonDigital
  # A class that returns acronym or full name of two main institutions. Returns empty string for anything else
  class InstitutionPicker
    class << self
      def institution_acronym(collection)
        return '' unless contains_university?(collection)

        institution = selected_institution(collection)
        translate_institution(institution, :acronym)
      end

      def institution_full_name(collection)
        return '' unless contains_university?(collection)

        institution = selected_institution(collection)
        translate_institution(institution, :full)
      end

      private

      def selected_institution(collection)
        collection.institution.map(&:to_s).&(osu + uo).first
      end

      def translate_institution(institution, translation_type)
        case translation_type
        when :acronym
          osu.include?(institution) ? 'OSU' : 'UO'
        when :full
          osu.include?(institution) ? 'Oregon State University' : 'University of Oregon'
        else
          ''
        end
      end

      def contains_university?(collection)
        !collection.institution.map(&:to_s).&(osu + uo).empty?
      end

      def osu
        ['http://id.loc.gov/authorities/names/n80017721']
      end

      def uo
        ['http://id.loc.gov/authorities/names/n80126183']
      end
    end
  end
end
