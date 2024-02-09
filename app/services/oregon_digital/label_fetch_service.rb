# frozen_string_literal: true

module OregonDigital
  # Label Fetch Service to fetch out data from uri and grouped as 'label$uri'
  class LabelFetchService
    # METHOD: Functionality to fetch all labels and put it as 'label$uri'
    def fetch_all_labels(controlled_vocabs)
      labels = fetch_labels_uris(controlled_vocabs)
      labels
    end

    private

    # METHOD: Fetching from RDF vocab and convert into 'label$uri'
    def fetch_labels_uris(controlled_vocabs)
      custom_labels = []
      controlled_vocabs.each do |cv|
        cv.fetch
        custom_labels << "#{cv.rdf_label.first}$#{cv.rdf_subject}"
      end
      custom_labels.flatten.compact
    end
  end
end
