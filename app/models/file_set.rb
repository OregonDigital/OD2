# frozen_string_literal:true

# Sets the expected behaviors for file sets
class FileSet < ActiveFedora::Base
  property :oembed_url, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/oembed'), multiple: false

  include ::Hyrax::FileSetBehavior
  include OregonDigital::AccessControls::Visibility

  def oembed?
    !oembed_url.nil? && !oembed_url.empty?
  end
end
