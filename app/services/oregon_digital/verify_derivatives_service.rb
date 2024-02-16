# frozen_string_literal:true

module OregonDigital
  ##
  # A service to verify that derivatives for the content exist for the migrated work
  class VerifyDerivativesService < VerifyService
    attr_reader :verification_errors

    # Given derivatives info from the original profile, verify that the derivatives
    # were successfully created after migrating the new work
    def verify
      @verification_errors = { derivatives: [] }
      return { derivatives: ['no file set'] } if no_fileset_warning

      @work.file_sets.each do |file_set|
        verify_file_set(file_set)
      end
      @verification_errors
    rescue StandardError => e
      @verification_errors[:derivatives] << e.message
      @verification_errors
    end

    def no_fileset_warning
      @work.file_sets.empty? && @work.class.to_s != 'Generic'
    end

    # rubocop:disable Metrics/AbcSize
    def verify_file_set(object)
      fsc = object.class
      case object.mime_type
      when *fsc.pdf_mime_types             then check_pdf_derivatives(object)
      when *fsc.office_document_mime_types then check_office_document_derivatives(object)
      when *fsc.audio_mime_types           then check_audio_derivatives(object)
      when *fsc.video_mime_types           then check_video_derivatives(object)
      when *fsc.image_mime_types           then check_image_derivatives(object)
      end
      @verification_errors[:derivatives] << 'Index problem (fileset)' unless index_info[:file_set]
    end
    # rubocop:enable Metrics/AbcSize

    def check_pdf_derivatives(file_set)
      check_thumbnail(file_set)
      check_page_count(file_set)
    end

    def check_office_document_derivatives(file_set)
      check_thumbnail(file_set)
      check_extracted_content(file_set)
    end

    def check_audio_derivatives(file_set)
      check_file_type(file_set, 'mp3')
    end

    def check_video_derivatives(file_set)
      check_thumbnail(file_set)
      check_file_type(file_set, 'mp4')
    end

    def check_image_derivatives(file_set)
      check_thumbnail(file_set)
      check_file_type(file_set, 'jp2')
    end

    def all_derivatives(file_set)
      Hyrax::DerivativePath.derivatives_for_reference(file_set).map { |f| File.basename(f) }
    end

    def check_thumbnail(file_set)
      has_thumbnail = work_info(file_set)[:has_thumbnail]
      if has_thumbnail
        @verification_errors[:derivatives] << 'Index problem (thumbnail)' unless index_info[:thumbnail]
      else
        @verification_errors[:derivatives] << 'Missing thumbnail' unless has_thumbnail == true
      end
    end

    def check_page_count(file_set)
      @verification_errors[:derivatives] << 'Missing pages' unless work_info(file_set)[:page_count].positive?
    end

    def check_extracted_content(file_set)
      @verification_errors[:derivatives] << 'Missing extracted text' unless work_info(file_set)[:has_extracted_text]
    end

    def check_file_type(file_set, extension)
      @verification_errors[:derivatives] << "Missing #{extension} derivative" unless derivatives_for_reference(file_set, extension).present?
    end

    def derivatives_for_reference(file_set, extension)
      all_derivatives(file_set).select { |b| File.extname(b) == ".#{extension}" }
    end

    def index_info
      @index_info ||=
        {
          thumbnail: !@solr_doc['thumbnail_path_ss'].blank?,
          file_set: !@solr_doc['file_set_ids_ssim'].blank?
        }
    end

    def work_info(file_set)
      @work_info ||=
        {
          file_set_id: file_set.id,
          has_thumbnail: all_derivatives(file_set).select { |b| b.match 'thumbnail' }.present?,
          has_extracted_text: file_set.extracted_text.present?,
          page_count: derivatives_for_reference(file_set, 'jp2').count
        }
    end
  end
end
