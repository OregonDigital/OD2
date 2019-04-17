# frozen_string_literal:true

# Indexer that indexes generic specific metadata
class GenericIndexer < Hyrax::WorkIndexer
  include OregonDigital::IndexesBasicMetadata
  include OregonDigital::IndexesLinkedMetadata

  def generate_solr_document
    super.tap do |solr_doc|
      rights_statement_labels = OregonDigital::RightsStatementService.new.all_labels(object.rights_statement)
      license_labels = OregonDigital::LicenseService.new.all_labels(object.license)
      language_labels = OregonDigital::LanguageService.new.all_labels(object.language)
      type_labels = OregonDigital::TypeService.new.all_labels(object.resource_type)

      index_rights_statement_label(solr_doc, rights_statement_labels)
      index_license_label(solr_doc, license_labels)
      index_language_label(solr_doc, language_labels)
      index_type_label(solr_doc, type_labels)
    end
  end

  def index_rights_statement_label(solr_doc, rights_statement_labels)
    solr_doc['rights_statement_label_sim'] = rights_statement_labels
    solr_doc['rights_statement_label_ssim'] = rights_statement_labels
    solr_doc['rights_statement_label_tesim'] = rights_statement_labels
  end

  def index_license_label(solr_doc, license_labels)
    solr_doc['license_label_sim'] = license_labels
    solr_doc['license_label_ssim'] = license_labels
    solr_doc['license_label_tesim'] = license_labels
  end

  def index_language_label(solr_doc, language_labels)
    solr_doc['language_label_sim'] = language_labels
    solr_doc['language_label_ssim'] = language_labels
    solr_doc['language_label_tesim'] = language_labels
  end

  def index_type_label(solr_doc, type_labels)
    solr_doc['type_label_sim'] = type_labels
    solr_doc['type_label_ssim'] = type_labels
    solr_doc['type_label_tesim'] = type_labels
  end
end
