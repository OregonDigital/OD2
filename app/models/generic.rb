# frozen_string_literal:true

# Sets the expected behaviors of a generic work
class Generic < ActiveFedora::Base
  include ::Hyrax::WorkBehavior
  attr_writer :graph_fetch_failures

  # before_create :prefetch_graphs
  before_save :resolve_oembed_errors

  self.indexer = GenericIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::OregonDigital::GenericMetadata

  def graph_fetch_failures
    @graph_fetch_failures ||= []
  end

  private

  def prefetch_graphs
    indexer = indexing_service.rdf_service.new(self, self.class.index_config)
    indexer.add_assertions(nil)
    graph_fetch_failures.uniq.each do |rdf_subject|
      enqueue_fetch_failure(rdf_subject)
    end
  end

  ##
  # Returns an RDF::Graph that is stored as a placeholder
  #
  # @param uri [RDF::Uri] the URI to fetch
  # @param [User] the user to alert about this failed fetch
  def enqueue_fetch_failure(uri)
    user = User.find_by_user_key(depositor)
    # Email user about failure
    Hyrax.config.callback.run(:ld_fetch_error, user, uri)

    FetchGraphWorker.perform_in(15.minutes, uri, user)
  end

  # If the oembed_url changed all previous errors are invalid
  def resolve_oembed_errors
    errors = OembedError.find_by(document_id: id)
    errors.delete if oembed_url_changed? && !errors.blank?
  end
end
