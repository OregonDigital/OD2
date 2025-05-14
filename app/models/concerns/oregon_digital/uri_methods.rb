# frozen_string_literal: true

module OregonDigital
  # create urls needed to point to asset show pages and representative images
  module UriMethods
    def iiif_url(pid)
      iiif_server + bucket_path(pid) + '-jp2.jp2/full/430,/0/default.jpg'
    end

    def bucket_path(pid)
      pid.gsub(/(.{2})/, '\1/')
    end

    def iiif_doc_url(pid)
      iiif_server + bucket_path(pid) + '-jp2-0000.jp2/full/430,/0/default.jpg'
    end

    def show_url(klass, pid)
      app_base_url + "concern/#{klass}/#{pid}"
    end

    def video_thumb(pid)
      app_base_url + thumbnail_path(pid)
    end

    # requires solr document to be decorated, i.e.
    # Hyrax::SolrDocument::OrderedMembers.decorate(doc)
    def assign_uris(doc)
      @asset_show_uri = show_url(doc['has_model_ssim'].first.downcase + 's', doc['id'])
      return image_uri(doc) unless doc['has_model_ssim'].first == 'Generic'

      return if doc.ordered_member_ids.blank?

      chdoc = SolrDocument.find(doc.ordered_member_ids.first)
      image_uri(chdoc)
    end

    def iiif_server
      uri = ENV.fetch('IIIF_SERVER_BASE_URL')
      uri.ends_with?('/') ? uri : uri + '/'
    end

    def app_base_url
      uri = Rails.application.routes.url_helpers.root_url
      uri.ends_with?('/') ? uri : uri + '/'
    end

    def thumbnail_path(pid)
      doc = Hyrax::SolrService.query("id:#{pid}", rows: 1).first
      doc['thumbnail_path_ss'].delete_prefix('/')
    end

    def image_uri(doc)
      return if doc['member_ids_ssim'].blank?

      case doc['has_model_ssim'].first
      when 'Image'
        @asset_image_uri = iiif_url(doc['member_ids_ssim'].first)
      when 'Document'
        @asset_image_uri = iiif_doc_url(doc['member_ids_ssim'].first)
      when 'Video'
        @asset_image_uri = video_thumb(doc['member_ids_ssim'].first)
      end
    end
  end
end
