# frozen_string_literal:true

IIIFManifest::ManifestBuilder::CanvasBuilder.class_eval do
  # Add a page number to the canvas URL so we can reference different canvases within the same sequence.
  def path
    page = record.label.respond_to?('gsub') ? record.label.gsub(/^.*Page ([0-9]*)$/, '\1').to_i : 0;
    page = [0, page - 1].max
    "#{parent.manifest_url}/canvas/#{record.id}/#{page}"
  end
end
