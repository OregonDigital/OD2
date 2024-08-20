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
    attr_accessor :asset_image_uri, :asset_show_uri, :work, :errors
    def initialize(work)
      @work = work
      @errors = []
    end

    def json
      JSON.generate(record)
    end

    # rubocop:disable Metrics/AbcSize
    def build_record
      record['dates'] = [add_date]
      record['title'] = work.title.first
      record['lang_materials'] = [lang]
      record['file_versions'] = file_versions
      record['digital_object_type'] = do_type
      record['linked_instances'] = [linked_instance]
      record['digital_object_id'] = work.identifier.first
      add_visibility
    end
    # rubocop:enable Metrics/AbcSize

    def linked_instance
      if work.archival_object_id.blank?
        errors << "#{work.id.to_s} has no archival_object_id"
        return {}

      end
      ao_id = work.archival_object_id.first.split('/').last
      { 'ref' => "/repositories/2/archival_objects/#{ao_id}" }
    end

    def record
      @record ||= {
        'jsonmodel_type' => 'digital_object',
        'is_slug_auto' => false,
        'extents' => []
      }
    end

    def add_visibility
      restrict = (work.visibility != 'open' || !work.access_restrictions.blank?)
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

    def add_date
      return {} if work.date.blank?

      date_hash.tap do |t|
        d = work.date.first
        t['expression'] = d
        arr = d.split('/')
        t['begin'] = arr[0]
        if arr.size > 1
          t['date_type'] = 'inclusive'
          t['end'] = arr[1]
        end
      end
    end

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
      assign_uris(work)
      [].tap do |a|
        a << build_file_version(file_version_embed, @asset_image_uri) if work.visibility == 'open'
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
      return {} if work.language.blank?

      {
        'jsonmodel_type' => 'lang_material',
        'language_and_script' => {
          'language' => work.language.first.split('/').last,
          'jsonmodel_type' => 'language_and_script'
        }
      }
    end

    # rubocop:disable Metrics/MethodLength
    def do_type
      case work.class.to_s
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
