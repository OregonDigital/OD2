# frozen_string_literal:true

module OregonDigital
  module CitationsBehaviors
    # Behavior to format authors and their names
    module NameBehavior
      include Hyrax::CitationsBehaviors::CommonBehavior
      include Hyrax::CitationsBehaviors::NameBehavior

      # return all unique authors of a work or nil if none
      def all_authors(work, &block)
        # OVERRIDE FROM HYRAX to grab creator_label as author
        authors = work.author_label.empty? ? [] : work.author_label.uniq.compact
        # END OVERRIDE
        block_given? ? authors.map(&block) : authors
      end

      def whitewash(text)
        Loofah.fragment(text.to_s).scrub!(:whitewash).to_s
      end
    end
  end
end
