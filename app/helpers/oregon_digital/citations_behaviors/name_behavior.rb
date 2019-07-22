# frozen_string_literal:true

module OregonDigital
  module CitationsBehaviors
    module NameBehavior
      include Hyrax::CitationsBehaviors::CommonBehavior
      include Hyrax::CitationsBehaviors::NameBehavior

      # return all unique authors of a work or nil if none
      def all_authors(work, &block)
        # OVERRIDE FROM HYRAX to grab creator_label as author
        authors = work.creator_label.uniq.compact
        # END OVERRIDE
        block_given? ? authors.map(&block) : authors
      end
    end
  end
end
