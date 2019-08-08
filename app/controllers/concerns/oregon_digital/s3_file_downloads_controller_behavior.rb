# frozen_string_literal: true

module OregonDigital
  # This is a blatant ripoff of the LocalFileDownloadsControllerBehavior from
  # Hyrax, retrofitted to handle S3 objects
  module S3FileDownloadsControllerBehavior
    protected

    # Handle the HTTP show request
    def send_s3_content
      response.headers['Accept-Ranges'] = 'bytes'
      if request.head?
        s3_content_head
      elsif request.headers['Range']
        send_range_for_s3_file
      else
        send_s3_file_contents
      end
    end

    # render an HTTP Range response
    def send_range_for_s3_file
      prepare_s3_range_headers
      prepare_s3_file_headers
      send_data s3_object.get(range: range).body.read, s3_derivative_download_options.merge(status: status)
    end

    def prepare_s3_range_headers
      from, to = parse_range
      length = to - from + 1
      range = "bytes #{from}-#{to}/#{s3_file_size}"
      response.headers['Content-Range'] = range
      response.headers['Content-Length'] = length.to_s
      self.status = 206
    end

    def parse_range
      _, range = request.headers['Range'].split('bytes=')
      from, to = range.split('-').map(&:to_i)
      to ||= s3_file_size - 1
      [from, to]
    end

    def send_s3_file_contents
      self.status = 200
      prepare_s3_file_headers
      send_data s3_object.get.body.read, s3_derivative_download_options
    end

    def s3_file_size
      s3_object.content_length
    end

    def s3_file_mime_type
      s3_object.content_type
    end

    # @return [String] the filename
    def s3_file_name
      params[:filename] || s3_object.key || (asset.respond_to?(:label) && asset.label)
    end

    def s3_file_last_modified
      s3_object.last_modified
    end

    # render an HTTP HEAD response
    def s3_content_head
      response.headers['Content-Length'] = s3_file_size.to_s
      head :ok, content_type: s3_file_mime_type
    end

    def prepare_s3_file_headers
      send_file_headers! s3_content_options
      prepare_content_headers
      prepare_modified_header
    end

    def prepare_content_headers
      response.headers['Content-Type'] = s3_file_mime_type
      response.headers['Content-Length'] ||= s3_file_size.to_s
      self.content_type = s3_file_mime_type
    end

    # This prevents Rack::ETag from calculating a digest over body
    def prepare_modified_header
      response.headers['Last-Modified'] = s3_file_last_modified.utc.strftime('%a, %d %b %Y %T GMT')
    end

    private

    # Override the Hydra::Controller::DownloadBehavior#content_options so that
    # we have an attachement rather than 'inline'
    def s3_content_options
      { type: s3_file_mime_type, filename: s3_file_name, disposition: 'attachment' }
    end

    # Override this method if you want to change the options sent when downloading
    # a derivative file
    def s3_derivative_download_options
      { type: s3_file_mime_type, filename: s3_file_name, disposition: 'inline' }
    end
  end
end
