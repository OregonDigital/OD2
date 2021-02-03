module OregonDigital
  # A class that returns acronym or full name of two main institutions. Returns empty string for anything else
  class CollectionInstitutionPicker
    def self.institution_acronym(collection)
      return "" unless contains_university?(collection)
      insitution = selected_institution(collection) 
      translate_institution(institution, :acronym)
    end

    def self.institution_full_name(collection)
      return "" unless contains_university?(collection)
      insitution = selected_institution(collection) 
      translate_institution(institution, :full)
    end

    private

    def selected_institution(collection)
      institution = ""
      institution = collection.institution.select { |val| val == osu }.first
      institution = collection.institution.select { |val| val == uo }.first if institution.blank?
      institution
    end

    def translate_institution(institution, translation_type)
      case translation_type
      when :acronym
        return institution == osu ? "OSU" : "UO"
      when :full
        return institution == osu ? "Oregon State University" : "University of Oregon"
      else
        return ""
      end
    end

    def contains_university?(collection)
      collection.institution.include?(uo) || collection.institution.include?(osu) 
    end

    def osu
      "http://id.loc.gov/authorities/names/n80017721"
    end

    def uo
      "http://id.loc.gov/authorities/names/n80126183"
    end
  end
end