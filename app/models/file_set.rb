# frozen_string_literal:true

# Sets the expected behaviors for file sets
class FileSet < ActiveFedora::Base
  include ::Hyrax::FileSetBehavior

  ##
  # Generate an encoded iiif url for this FileSet
  # @param base_url [String] : provided by iiif_image_url_builder or
  # iiif_info_url_builder, looks like http://localhost
  # @return [String] : a url to the iiif server with a properly encoded identifier,
  # looks like http://IIIFSERVER/ab%2fcd%2f12%2f24%2fz-jp2.jp2
  def iiif_url(base_url)
    iiif_server_base_url = ENV.fetch('IIIF_SERVER_BASE_URL', base_url)
    jp2_file = derivative_path_for_reference('jp2')
    file_type = File.exist?(jp2_file) ? '-jp2.jp2' : '-jpg.jpg'

    iiif_identifier = id.scan(/.{1,2}/).join('%2f')
    # iiif_identifier : ab%2fcd%2f12%2f24%2fz-jp2.jp2
    iiif_identifier += file_type
    "#{iiif_server_base_url}/#{iiif_identifier}"
  end

  private

  def derivative_path_for_reference(destination_name)
    Hyrax::DerivativePath.derivative_path_for_reference(self, destination_name)
  end
end
