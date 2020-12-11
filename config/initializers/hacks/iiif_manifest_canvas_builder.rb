# frozen_string_literal:true

IIIFManifest::ManifestBuilder::CanvasBuilder.class_eval do
  # Add a page number to the canvas URL so we can reference different canvases within the same sequence.
  def path
    page = record.label.gsub(/^.*Page ([0-9]*)$/, '\1').to_i
    "#{parent.manifest_url}/canvas/#{record.id}/#{page}"
  end
end
