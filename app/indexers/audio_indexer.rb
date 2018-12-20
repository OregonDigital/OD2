# frozen_string_literal:true

class AudioIndexer < GenericIndexer
  def generate_solr_document
    super.tap do |solr_doc|
    end
  end
end
