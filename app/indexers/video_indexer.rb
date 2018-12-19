# frozen_string_literal:true

class VideoIndexer < GenericIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      OregonDigital::VideoMetadata::PROPERTIES.map(&:to_s).each do |prop|
        if !object.attributes[prop.to_s].is_a? ActiveTriples::Relation
          solr_doc["#{prop}_tesim"] = object.attributes[prop].nil? ? "" : object.attributes[prop] 
        else
          solr_doc["#{prop}_tesim"] = object.attributes[prop].to_a.blank? ? [""] : object.attributes[prop].to_a  
        end
      end
    end
  end
end
