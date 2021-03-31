# frozen_string_literal:true

module Hyrax
  # Generated form for Video
  class VideoForm < Hyrax::GenericForm
    self.model_class = ::Video
    self.terms += Video.video_properties.map(&:to_sym)
    self.terms = self.terms.uniq

    def primary_terms
      # Push the required fields to the top of the form
      # Then make sure they arent rendered again lower in the form
      required_fields + (Video::ORDERED_TERMS - required_fields) -
        %i[alternative_title access_right rights_notes
           files visibility_during_embargo embargo_release_date
           visibility_after_embargo visibility_during_lease
           lease_expiration_date visibility_after_lease visibility
           thumbnail_id representative_id rendering_ids ordered_member_ids
           member_of_collection_ids in_works_ids admin_set_id]
    end
  end
end
