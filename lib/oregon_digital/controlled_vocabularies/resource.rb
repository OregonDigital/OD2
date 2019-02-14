# frozen_string_literal: true

module OregonDigital
  module ControlledVocabularies
    # Generic object for storing labels and uris
    class Resource < ActiveTriples::Resource
      ##
      # Override ActiveTriples::Resource to enforce vocabulary membership
      #
      # @see ActiveTriples::Resource
      def initialize(*args, &block)
        super
        # If rdf_subject wasn't set, we're done
        return if node?

        # Reset rdf_subject and set it through the proper method
        resource_uri = @rdf_subject
        @rdf_subject = nil
        set_subject!(resource_uri)
      end

      # Override ActiveTriples::Resource.set_subject! to throw exception if term isn't in vocab
      def set_subject!(uri_or_str)
        raise ControlledVocabularyError, "Term not in controlled vocabulary: #{uri_or_str}" unless
          uri_in_vocab?(uri_or_str.to_s)
        super
      end

      # Return a tuple of url & label
      def solrize
        return [rdf_subject.to_s] if rdf_label.first.to_s.blank? || rdf_label_uri_same?
        [rdf_subject.to_s, { label: "#{rdf_label.first}$#{rdf_subject}" }]
      end

      private

      def rdf_label_uri_same?
        rdf_label.first.to_s == rdf_subject.to_s
      end

      def uri_in_vocab?(uri)
        self.class.respond_to?(:in_vocab?) && self.class.in_vocab?(uri)
        true
      end
    end

    class ControlledVocabularyError < StandardError; end
  end
end
