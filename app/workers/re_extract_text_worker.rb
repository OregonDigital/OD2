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
    file_set = FileSet.find pid
    # Create extracted text bbox_content
    OregonDigital::ExtractedTextDerivativeService::Factory.new(file_set: file_set, filename: filename).new.create_derivatives
    # We need the individual pages as PNGs to redo the OCR, but we can skip it if we were able to extract the exact text
    page_count = OregonDigital::Derivatives::Image::Utils.page_count(filename)

    # Create the fileset derivative service and use it to iterate the existing jp2 derivatives
    derivative_service = OregonDigital::FileSetDerivativesService.new(file_set)

    # OCR if we didn't get extracted bbox content
    if file_set.bbox_content.blank?
      file_set.ocr_content = []
      file_set.hocr_content = []
      file_set.hocr_text = []
      0.upto(page_count - 1) do |pagenum|
        Rails.logger.debug("HOCR: page #{pagenum}/#{page_count - 1}")

        # This jp2 needs to be converted to png before it can be OCRd by tesseract
        OregonDigital::Derivatives::Image::Utils.tmp_file('png') do |out_path|
          derivative_service.manual_convert(filename, pagenum, out_path)
          OregonDigital::HocrDerivativeService::Factory.new(file_set: file_set, filename: out_path, pagenum: pagenum).new.create_derivatives
        end
      end
    end

    file_set.update_index
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
