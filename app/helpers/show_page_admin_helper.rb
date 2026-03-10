# frozen_string_literal: true

# provide logic for building link to importer
# note that if bulkrax_identifier_sim has more than one value, they likely are ordered from newest to oldest
# the importer that is chosed for bulkrax_importer_id_sim is based on the oldest importer
# in order to display the matching entry identifier, we are using the last value from bulkrax_identifier
module ShowPageAdminHelper
  def show_importer_link(solr_doc, base_url)
    return 'not found' if solr_doc['bulkrax_identifier_sim'].blank?

    return "#{solr_doc['bulkrax_identifier_sim'].first}: not found" unless importer_exists?(solr_doc['bulkrax_importer_id_sim'])

    return link_to(solr_doc['bulkrax_identifier_sim'].first, "#{base_url}#{bulkrax.importer_path(solr_doc['bulkrax_importer_id_sim'].last)}", target: '_blank')
  end

  def importer_exists?(importer_id)
    return false if importer_id.blank?

    Bulkrax::Importer.exists? importer_id.first
  end
end
