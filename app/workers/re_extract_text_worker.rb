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
    file_set = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: pid)
    # Create extracted text bbox_content
    OregonDigital::Derivatives::Document::PDFToTextRunner.create(filename,
                                                                outputs: [{ url: uri(file_set), container: 'bbox' }])
    # We need the individual pages as PNGs to redo the OCR, but we can skip it if we were able to extract the exact text
    page_count = OregonDigital::Derivatives::Image::Utils.page_count(filename)

    # OCR if we didn't get extracted bbox content
    if file_set.bbox_content.blank?
      # Create the fileset derivative service and use it to iterate the existing jp2 derivatives
      derivative_service = OregonDigital::FileSetDerivativesService.new(file_set)
      file_set.ocr_content = []
      file_set.hocr_text = []
      0.upto(page_count - 1) do |pagenum|
        Rails.logger.debug("HOCR: page #{pagenum}/#{page_count - 1}")

        # This jp2 needs to be converted to png before it can be OCRd by tesseract
        OregonDigital::Derivatives::Image::Utils.tmp_file('png') do |out_path|
          derivative_service.manual_convert(filename, pagenum, out_path)
          OregonDigital::Derivatives::Document::TesseractRunner.create(out_path,
                                                                    outputs: [{ url: uri(file_set), container: 'hocr' }])
        end
      end
    end

    file_set.update_index
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
