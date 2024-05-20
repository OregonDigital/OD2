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

      file_sets.each do |file_set|
        verify_file_set(file_set)
      end
      @verification_errors
    rescue StandardError => e
      @verification_errors[:derivatives] << e.message
      @verification_errors
    end

    def file_sets
      @file_sets ||= Hyrax.custom_queries.find_child_file_sets(resource: @work)
    end

    def mime_type(file_set)
      file_metadata(file_set).mime_type
    end

    def file_metadata(file_set)
      Hyrax.custom_queries.find_files(file_set: file_set).first
    end

    def no_fileset_warning
      file_sets.empty? && @work.class.to_s != 'Generic'
    end

    # rubocop:disable Metrics/AbcSize
    def verify_file_set(file_set)
      case mime_type(file_set)
      when FileSet.pdf_mime_types             then check_pdf_derivatives(object)
      when FileSet.office_document_mime_types then check_office_document_derivatives(object)
      when FileSet.audio_mime_types           then check_audio_derivatives(object)
      when FileSet.video_mime_types           then check_video_derivatives(object)
      when FileSet.image_mime_types           then check_image_derivatives(object)
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
      # TODO: restore this check when we know more about extracted_text
      # check_extracted_content(file_set)
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
          has_thumbnail: all_derivatives(file_set).select { |b| b.match 'thumbnail' }.present?,
          # has_extracted_text: file_set.bbox.present?,
          page_count: derivatives_for_reference(file_set, 'jp2').count
        }
    end
  end
end
