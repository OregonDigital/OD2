# frozen_string_literal:true

# Indexer that indexes generic specific metadata
# rubocop:disable Metrics/ClassLength
class GenericIndexer < Hyrax::WorkIndexer
  include OregonDigital::IndexesBasicMetadata
  include OregonDigital::IndexesLinkedMetadata
  include OregonDigital::IndexingDatesBehavior
  include OregonDigital::StripsStopwords
  include OregonDigital::ParsableLabelBehavior

  # ABC Size is hard to avoid here because there are many types of fields we need to index.
  # Pulling them out of #generate_solr_document and creating their own methods causes this issue to
  # propogate downwards.
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/BlockLength
  def generate_solr_document
    super.tap do |solr_doc|
      index_rights_statement_label(solr_doc, object)
      index_full_size_download_allowed_label(solr_doc, OregonDigital::DownloadService.new.all_labels(object.full_size_download_allowed))
      index_license_label(solr_doc, object)
      index_copyright_combined_label(solr_doc, OregonDigital::LicenseService.new.all_labels(object.license), OregonDigital::RightsStatementService.new.all_labels(object.rights_statement))
      index_language_label(solr_doc, object)
      index_type_label(solr_doc, object)
      index_local_contexts_label(solr_doc, object)
      index_sort_options(solr_doc)
      label_fetch_properties_solr_doc(object, solr_doc)
      solr_doc['non_user_collections_label_ssim'] = []
      solr_doc['non_user_collections_ssim'] = []
      solr_doc['user_collections_ssim'] = []
      solr_doc['oai_collections_ssim'] = []
      object.member_of_collections.each do |collection|
        collection_index_key = collection_indexing_key(collection.collection_type.machine_id)
        solr_doc[collection_index_key] << collection.id
        solr_doc[collection_index_key.gsub('_ssim', '_tesim')] = collection.title
        solr_doc['non_user_collections_label_ssim'] << collection.title if collection_index_key == 'non_user_collections_ssim'
      end
      # removing index_topic_combined_label(solr_doc, object.keyword)
      # will be handled when indexing fetched labels
      index_edit_groups
      index_read_groups
      index_discover_groups
      solr_doc['all_text_timv'] = object.file_sets.map { |file_set| find_all_text_value(file_set) }
      solr_doc['hocr_text_timv'] = object.file_sets.map { |file_set| find_hocr_text(file_set) }
      solr_doc['file_format_sim'] = object.file_sets.map { |file_set| file_set.to_solr['file_format_sim'] } # Index file formats from file sets for faceting
      # for bulkrax
      solr_doc['bulkrax_identifier_sim'] = object.bulkrax_identifier
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/BlockLength

  def collection_indexing_key(machine_id)
    case machine_id
    when 'user_collection'
      'user_collections_ssim'
    when 'oai_set'
      'oai_collections_ssim'
    else
      'non_user_collections_ssim'
    end
  end

  def find_all_text_value(file_set)
    file_set.extracted_text&.content.presence
  end

  def find_hocr_text(file_set)
    file_set.hocr_text
  end

  def index_copyright_combined_label(solr_doc, license_labels, rights_labels)
    solr_doc['copyright_combined_label_sim'] = license_labels + rights_labels
    solr_doc['copyright_combined_label_tesim'] = license_labels + rights_labels
  end

  def index_full_size_download_allowed_label(solr_doc, full_size_download_allowed_labels)
    solr_doc['full_size_download_allowed_label_sim'] = full_size_download_allowed_labels
    solr_doc['full_size_download_allowed_label_ssim'] = full_size_download_allowed_labels
    solr_doc['full_size_download_allowed_label_tesim'] = full_size_download_allowed_labels
  end

  def index_rights_statement_label(solr_doc, object)
    rights_statement_labels = OregonDigital::RightsStatementService.new.all_labels(object.rights_statement)
    solr_doc['rights_statement_label_sim'] = rights_statement_labels
    solr_doc['rights_statement_label_ssim'] = rights_statement_labels
    solr_doc['rights_statement_label_tesim'] = rights_statement_labels
    solr_doc['rights_statement_parsable_label_ssim'] = object.rights_statement.map { |uri| "#{OregonDigital::RightsStatementService.new.label(uri)}$#{uri}" }
  end

  def index_license_label(solr_doc, object)
    license_labels = OregonDigital::LicenseService.new.all_labels(object.license)
    solr_doc['license_label_sim'] = license_labels
    solr_doc['license_label_ssim'] = license_labels
    solr_doc['license_label_tesim'] = license_labels
    solr_doc['license_parsable_label_ssim'] = object.license.map { |uri| "#{OregonDigital::LicenseService.new.label(uri)}$#{uri}" }
  end

  def index_language_label(solr_doc, object)
    language_labels = OregonDigital::LanguageService.new.all_labels(object.language)
    solr_doc['language_label_sim'] = language_labels
    solr_doc['language_label_ssim'] = language_labels
    solr_doc['language_label_tesim'] = language_labels
    solr_doc['language_parsable_label_ssim'] = object.language.map { |uri| "#{OregonDigital::LanguageService.new.label(uri)}$#{uri}" }
  end

  def index_type_label(solr_doc, object)
    type_label = OregonDigital::TypeService.new.all_labels(object.resource_type)
    solr_doc['resource_type_label_sim'] = type_label
    solr_doc['resource_type_label_ssim'] = type_label
    solr_doc['resource_type_label_tesim'] = type_label
    solr_doc['resource_type_parsable_label_ssim'] = "#{OregonDigital::TypeService.new.label(object.resource_type)}$#{object.resource_type}"
  end

  # METHOD: Create index for local_context
  def index_local_contexts_label(solr_doc, object)
    local_context_labels = OregonDigital::LocalContextsService.new.all_labels(object.local_contexts)
    solr_doc['local_contexts_label_sim'] = local_context_labels
    solr_doc['local_contexts_label_ssim'] = local_context_labels
    solr_doc['local_contexts_label_tesim'] = local_context_labels
    solr_doc['local_contexts_parsable_label_ssim'] = object.local_contexts.map { |uri| "#{OregonDigital::LocalContextsService.new.label(uri)}$#{uri}" }
  end

  def index_sort_options(solr_doc)
    solr_doc['title_ssort'] = strip_stopwords(object.first_title)
    solr_doc['date_dtsi'] = object.date.map do |date|
      # Try a basic parse first, we're not officially supporting EDTF yet until the gem updates for all of 2012+ spec is included
      DateTime.parse(date)
    rescue Date::Error
      # But singular years can slip through and some edge cases might best be captured with EDTF
      edtf = Date.edtf(date)
      edtf = edtf.first if edtf.is_a? EDTF::Interval
      edtf&.to_datetime
    end.compact.first
  end

  def index_edit_groups
    object.edit_groups = (object.edit_groups + %w[admin collection_curator]).uniq
  end

  def index_read_groups
    object.read_groups = (object.edit_groups + object.read_groups + %w[admin collection_curator depositor]).uniq
  end

  def index_discover_groups
    object.discover_groups = discoverable_groups
  end

  def discoverable_groups
    groups = (all_existing_groups + %w[admin collection_curator depositor]).uniq
    groups -= ['public'] if object.visibility != 'public'
    groups -= ['uo'] if object.visibility != 'uo'
    groups -= ['osu'] if object.visibility != 'osu'
    groups
  end

  def all_existing_groups
    (object.edit_groups + object.read_groups + object.discover_groups)
  end
end
# rubocop:enable Metrics/ClassLength
