# frozen_string_literal:true

class ImageIndexer < GenericIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      OregonDigital::ImageMetadata::PROPERTIES.map(&:to_s).each do |prop|
        attr = object.attributes[prop]
        if attr.is_a? ActiveTriples::Relation
          index_value_for_multiple(solr_doc, attr, prop)
        else
          index_value_for_singular(solr_doc, attr, prop)
        end
      end
    end
  end
end
