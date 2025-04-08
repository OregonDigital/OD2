# frozen_string_literal:true

module OregonDigital
  # Digital Object for import into ArchivesSpace
  # rubocop:disable Metrics/ClassLength
  class AspaceDigitalObject
    require 'edtf'
    include UriMethods

    # Aspace required(?) keys for new digital object:
    # jsonmodel_type, extents, lang_materials, dates, is_slug_auto,
    # file_versions, restrictions, title, digital_object_id
    # image_uri is the iiif path, show_uri is the show page
    attr_accessor :asset_image_uri, :asset_show_uri, :doc, :errors
    def initialize(pid)
      @doc = SolrDocument.find pid
      @errors = []
    end

    def json
      JSON.dump(record)
    end

    # rubocop:disable Metrics/AbcSize
    def build_record
      record['dates'] = [add_date]
      record['title'] = doc['title_tesim'].first
      record['lang_materials'] = [lang]
      record['file_versions'] = file_versions
      record['digital_object_type'] = do_type
      record['linked_instances'] = [linked_instance]
      record['digital_object_id'] = doc['identifier_tesim'].first
      add_visibility
    end
    # rubocop:enable Metrics/AbcSize

    def linked_instance
      if doc['archival_object_id_tesim'].blank?
        errors << "#{doc['id']} has no archival_object_id"
        return {}

      end
      val = doc['archival_object_id_tesim'].first.split('/').last
      id_match = /[0-9]+/.match val
      return {} if id_match.nil?

      { 'ref' => "/repositories/2/archival_objects/#{id_match.to_s}" }
    end

    def record
      @record ||= {
        'jsonmodel_type' => 'digital_object',
        'is_slug_auto' => false,
        'extents' => []
      }
    end

    def add_visibility
      restrict = (doc['visibility_ssi'] != 'open' || !doc['access_restrictions_tesim'].blank?)
      record['publish'] = true
      record['restrictions'] = restrict
      record['suppressed'] = false
    end

    def date_hash
      {
        'label' => 'creation',
        'jsonmodel_type' => 'date',
        'date_type' => 'single'
      }
    end

    def date_present
      return doc['date_tesim'].first unless doc['date_tesim'].blank?

      return doc['date_created_tesim'].first unless doc['date_created_tesim'].blank?
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def add_date
      d = date_present
      return {} if d.nil?

      return {} unless EDTF.parse(d).present?

      date_hash.tap do |t|
        t['expression'] = d
        arr = d.split('/')
        t['begin'] = arr[0]
        if arr.size > 1
          t['date_type'] = 'inclusive'
          t['end'] = arr[1]
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def file_version_keys
      %w[publish is_representative use_statement xlink_actuate_attribute xlink_show_attribute]
    end

    def file_version_embed
      [true, true, 'image-thumbnail', 'onLoad', 'embed']
    end

    def file_version_show
      [true, false, 'image-service', 'onRequest', 'new']
    end

    def file_versions
      assign_uris(doc)
      [].tap do |a|
        a << build_file_version(file_version_embed, @asset_image_uri) if doc['visibility_ssi'] == 'open'
        a << build_file_version(file_version_show, @asset_show_uri)
      end
    end

    def build_file_version(arr, uri)
      {}.tap do |h|
        file_version_keys.each_with_index do |k, i|
          h[k] = arr[i]
        end
        h['file_uri'] = uri
      end
    end

    def lang
      return {} if doc['language_tesim'].blank?

      {
        'jsonmodel_type' => 'lang_material',
        'language_and_script' => {
          'language' => doc['language_tesim'].first.split('/').last,
          'jsonmodel_type' => 'language_and_script'
        }
      }
    end

    # rubocop:disable Metrics/MethodLength
    def do_type
      case doc['has_model_ssim'].first
      when 'Document'
        return 'Text'
      when 'Image'
        return 'Still Image'
      when 'Generic'
        return 'Mixed Materials'
      when 'Video'
        return 'moving_image'
      when 'Audio'
        return 'sound_recording_nonmusical'
      else
        return nil
      end
    end
    # rubocop:enable Metrics/MethodLength
  end
  # rubocop:enable Metrics/ClassLength
end
