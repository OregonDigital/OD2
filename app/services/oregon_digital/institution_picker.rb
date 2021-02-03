module OregonDigital
  # A class that returns acronym or full name of two main institutions. Returns empty string for anything else
  class InstitutionPicker
    def self.institution_acronym(collection)
      return "" unless contains_university?(collection)

      institution = selected_institution(collection) 
      translate_institution(institution, :acronym)
    end

    def self.institution_full_name(collection)
      return "" unless contains_university?(collection)

      institution = selected_institution(collection) 
      translate_institution(institution, :full)
    end

    private

    def self.selected_institution(collection)
      institution = ""
      institution = collection.institution.select { |val| val == osu }.first
      institution = collection.institution.select { |val| val == uo }.first if institution.blank?
      institution
    end

    def self.translate_institution(institution, translation_type)
      case translation_type
      when :acronym
        institution == osu ? "OSU" : "UO"
      when :full
        institution == osu ? "Oregon State University" : "University of Oregon"
      else
        ""
      end
    end

    def self.contains_university?(collection)
      collection.institution.include?(uo) || collection.institution.include?(osu) 
    end

    def self.osu
      "http://id.loc.gov/authorities/names/n80017721"
    end

    def self.uo
      "http://id.loc.gov/authorities/names/n80126183"
    end
  end
end