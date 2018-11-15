module OregonDigital::TriplePoweredProperties
  class WorkIndexer < Hyrax::WorkIndexer

    ##
    # Iterate through each of the triple powered properties to store its labels in solr
    def generate_solr_document
      super.tap do |solr_doc|
        unless self.object.triple_powered_properties.nil?
          self.object.triple_powered_properties.each do |p|
            labels = self.object.uri_labels(p).values.flatten.compact
            solr_doc[Solrizer.solr_name(p.to_s)] = labels
          end
        end
      end
    end
  end
end