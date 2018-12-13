# frozen_string_literal:true

class GenericIndexer < Hyrax::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior

  # Uncomment this block if you want to add custom indexing behavior:
  def generate_solr_document
   super.tap do |solr_doc|
     OregonDigital::GenericMetadata::PROPERTIES.map(&:to_s).each do |prop|
      solr_doc["#{prop}_ssim"] = object.attributes[prop.to_s]
      solr_doc["#{prop}_tesim"] = object.attributes[prop.to_s]
     end
   end
  end
end
