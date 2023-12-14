# frozen_string_literal: true

Rails.application.config.to_prepare do
  Hyrax::ValkyrieWorkIndexer.class_eval do
    def to_solr
      super.tap do |solr_doc|
        solr_doc['generic_type_si'] = 'Work'
        solr_doc['suppressed_bsi'] = suppressed?(resource)
        solr_doc['admin_set_id_ssim'] = [resource.admin_set_id.to_s]
        admin_set_label = admin_set_label(resource)
        solr_doc['admin_set_sim']   = admin_set_label
        solr_doc['admin_set_tesim'] = admin_set_label
        solr_doc["#{Hyrax.config.admin_set_predicate.qname.last}_ssim"] = [resource.admin_set_id.to_s]
        solr_doc['member_of_collection_ids_ssim'] = resource.member_of_collection_ids.map(&:to_s)
        solr_doc['member_ids_ssim'] = resource.member_ids.map(&:to_s)
        solr_doc['depositor_ssim'] = [resource.depositor]
        solr_doc['depositor_tesim'] = [resource.depositor]
        solr_doc['hasRelatedMediaFragment_ssim'] = [resource.representative_id.to_s]
        solr_doc['hasRelatedImage_ssim'] = [resource.thumbnail_id.to_s]
        # Add workflow_state_name_ssim
        solr_doc['workflow_state_name_ssim'] = Sipity::Entity(resource).workflow_state_name
      end
    end
  end
end
