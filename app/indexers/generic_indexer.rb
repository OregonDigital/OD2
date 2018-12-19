# frozen_string_literal:true

class GenericIndexer < Hyrax::WorkIndexer
  include OregonDigital::IndexesBasicMetadata
  include OregonDigital::IndexesLinkedMetadata

  # Uncomment this block if you want to add custom indexing behavior:
  def generate_solr_document
    super.tap do |solr_doc|
      OregonDigital::GenericMetadata::PROPERTIES.map(&:to_s).each do |prop|
        if !object.attributes[prop.to_s].is_a? ActiveTriples::Relation
          solr_doc["#{prop}_tesim"] = object.attributes[prop].nil? ? "" : object.attributes[prop] 
          solr_doc["#{prop}_sim"] = object.attributes[prop].nil? ? "" : object.attributes[prop] 
          solr_doc["#{prop}_ssim"] = object.attributes[prop].nil? ? "" : object.attributes[prop] 
        else
          solr_doc["#{prop}_tesim"] = object.attributes[prop].to_a.blank? ? [""] : object.attributes[prop].to_a  
          solr_doc["#{prop}_sim"] = object.attributes[prop].to_a.blank? ? [""] : object.attributes[prop].to_a  
          solr_doc["#{prop}_ssim"] = object.attributes[prop].to_a.blank? ? [""] : object.attributes[prop].to_a  
        end
      end
    end
  end
end
