# frozen_string_literal:true

# Indexer that indexes generic specific metadata
class GenericIndexer < Hyrax::WorkIndexer
  include OregonDigital::IndexesBasicMetadata
  include OregonDigital::IndexesLinkedMetadata

  def generate_solr_document
    super.tap do |solr_doc|
      OregonDigital::GenericMetadata::PROPERTIES.map(&:to_s).each do |prop|
        attr = object.attributes[prop]
        if ['date_created', 'date_uploaded'].include? prop
          solr_doc["#{prop}_tesim"] = [Date.today] if object.attributes[prop].empty?
        elsif attr.is_a? ActiveTriples::Relation
          index_value_for_multiple(solr_doc, attr, prop)
        else
          index_value_for_singular(solr_doc, attr, prop)
        end
      end
    end
  end

  private

  def index_value_for_multiple(solr_doc, attr, prop)
    solr_doc["#{prop}_tesim"] = attr.to_a.blank? ? [''] : attr.to_a
    solr_doc["#{prop}_sim"] = attr.to_a.blank? ? [''] : attr.to_a
    solr_doc["#{prop}_ssim"] = attr.to_a.blank? ? [''] : attr.to_a
  end

  def index_value_for_singular(solr_doc, attr, prop)
    solr_doc["#{prop}_tesim"] = attr.nil? ? '' : attr
    solr_doc["#{prop}_sim"] = attr.nil? ? '' : attr
    solr_doc["#{prop}_ssim"] = attr.nil? ? '' : attr
  end
end
