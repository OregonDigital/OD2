# frozen_string_literal:true

# Indexer that indexes generic specific metadata
class GenericIndexer < Hyrax::WorkIndexer
  include OregonDigital::IndexesBasicMetadata
  include OregonDigital::IndexesLinkedMetadata

  # ABC Size is hard to avoid here because there are many types of fields we need to index.
  # Pulling them out of #generate_solr_document and creating their own methods causes this issue to
  # propogate downwards.
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def generate_solr_document
    super.tap do |solr_doc|
      index_rights_statement_label(solr_doc, OregonDigital::RightsStatementService.new.all_labels(object.rights_statement))
      index_license_label(solr_doc, OregonDigital::LicenseService.new.all_labels(object.license))
      index_copyright_combined_label(solr_doc, OregonDigital::LicenseService.new.all_labels(object.license), OregonDigital::RightsStatementService.new.all_labels(object.rights_statement))
      index_language_label(solr_doc, OregonDigital::LanguageService.new.all_labels(object.language))
      index_type_label(solr_doc, OregonDigital::TypeService.new.all_labels(object.resource_type))
      solr_doc['non_user_collections_ssim'] = []
      object.member_of_collections.each do |collection|
        solr_doc['non_user_collections_ssim'] << collection.first_title unless collection.collection_type.machine_id == 'user_collection'
      end
      index_topic_combined_label(solr_doc, object.keyword)
      index_date_combined_label(solr_doc)
      index_edit_groups
      index_read_groups
      index_discover_groups
      solr_doc['all_text_tsimv'] = object.file_sets.map { |file_set| file_set.extracted_text.content unless file_set.extracted_text.nil? }
      # Index file formats from file sets for faceting
      solr_doc['file_format_sim'] = object.file_sets.map { |file_set| file_set.to_solr['file_format_sim'] }
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def index_copyright_combined_label(solr_doc, license_labels, rights_labels)
    solr_doc['copyright_combined_label_sim'] = license_labels + rights_labels
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

  def index_type_label(solr_doc, type_label)
    solr_doc['type_label_sim'] = type_label
    solr_doc['type_label_ssim'] = type_label
    solr_doc['type_label_tesim'] = type_label
  end

  def index_topic_combined_label(solr_doc, topic_labels)
    solr_doc['topic_combined_label_sim'] = topic_labels
  end

  def index_date_combined_label(solr_doc)
    dates = %i[award_date date_created collected_date date issued view_date acquisition_date]
    solr_doc['date_combined_label_sim'] = []
    dates.each do |date|
      solr_doc['date_combined_label_sim'] += object[date].to_a
    end
  end

  def index_edit_groups
    object.edit_groups = (object.edit_groups + %w[admin collection_curator]).uniq
  end

  def index_read_groups
    object.read_groups = (object.edit_groups + object.read_groups + %w[admin collection_curator depositor]).uniq
  end

  def index_discover_groups
    object.discover_groups = (object.edit_groups + object.read_groups + object.discover_groups + %w[admin collection_curator depositor]).uniq
  end
end
