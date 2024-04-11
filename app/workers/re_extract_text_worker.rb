# frozen_string_literal: true

# ReExtractTextWorker is a small worker to extract text from an existing fileset.
# Uses 'reindex' queue.
class ReExtractTextWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'reindex' # Use the 'reindex' queue

  # A fileset and the file path on disk is required
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def perform(pid, filename)
    file_set = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: pid, use_valkyrie: false)
    derivative_service = OregonDigital::FileSetDerivativesService.new(file_set)

    # Create extracted text bbox_content
    Hydra::Derivatives::FullTextExtract.create(filename,
                                               outputs: [{ url: uri(file_set), container: 'extracted_text' }])

    derivative_service.create_extracted_text_bbox_content(filename)

    # OCR if we didn't get extracted bbox content
    if file_set.extracted_text&.content.blank?
      # Reset the hocr content
      file_set.hocr = []
      # We need the individual pages as PNGs to redo the OCR, but we can skip it if we were able to extract the exact text
      page_count = OregonDigital::Derivatives::Image::Utils.page_count(filename)

      # Create the fileset derivative service and use it to iterate the existing jp2 derivatives
      0.upto(page_count - 1) do |pagenum|
        Rails.logger.debug("HOCR: page #{pagenum}/#{page_count - 1}")

        # This jp2 needs to be converted to png before it can be OCRd by tesseract
        OregonDigital::Derivatives::Image::Utils.tmp_file('png') do |out_path|
          derivative_service.manual_convert(filename, pagenum, out_path)
          derivative_service.create_hocr_content(out_path)
        end
      end
    end

    file_set.save
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def uri(file_set)
    # If given a FileMetadata object, use its parent ID.
    if file_set.respond_to?(:file_set_id)
      file_set.file_set_id.to_s
    else
      file_set.uri
    end
  end
end
