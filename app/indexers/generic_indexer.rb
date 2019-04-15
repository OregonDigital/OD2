# frozen_string_literal:true

# Indexer that indexes generic specific metadata
class GenericIndexer < Hyrax::WorkIndexer
  include OregonDigital::IndexesBasicMetadata
  include OregonDigital::IndexesLinkedMetadata

  def generate_solr_document
    super.tap do |solr_doc|
      rights_statement_labels = OregonDigital::RightsStatementService.new.all_labels(object.rights_statement)
      language_labels = OregonDigital::LanguageService.new.all_labels(object.language)
      type_labels = OregonDigital::TypeService.new.all_labels(object.resource_type)

      index_rights_statement(solr_doc, rights_statement_labels)
      solr_doc['language_label_ssim'] = language_labels
      solr_doc['language_label_tesim'] = language_labels
      solr_doc['type_label_ssim'] = type_labels
      solr_doc['type_label_tesim'] = type_labels
    end
  end

  def index_rights_statement(solr_doc, rights_statement_labels)
    solr_doc['rights_statement_label_ssim'] = rights_statement_labels
    solr_doc['rights_statement_label_tesim'] = rights_statement_labels
  end
end
