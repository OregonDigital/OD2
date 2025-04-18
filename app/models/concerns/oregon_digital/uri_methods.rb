# frozen_string_literal: true

require 'uri'
module OregonDigital
  # create urls needed to point to asset show pages and representative images
  module UriMethods
    def iiif_url(pid)
      URI.join(iiif_server, bucket_path(pid) + '-jp2.jp2/full/430,/0/default.jpg').to_s
    end

    def bucket_path(pid)
      pid.gsub(/(.{2})/, '\1/')
    end

    def iiif_doc_url(pid)
      URI.join(iiif_server, bucket_path(pid) + '-jp2-0000.jp2/full/430,/0/default.jpg').to_s
    end

    def show_url(klass, pid)
      URI.join(app_base_url, "concern/#{klass}/#{pid}").to_s
    end

    def video_thumb(pid)
      doc = Hyrax::SolrService.query("id:#{pid}", rows: 1).first
      URI.join(app_base_url, doc['thumbnail_path_ss']).to_s
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
      ENV.fetch('IIIF_SERVER_BASE_URL')
    end

    def app_base_url
      Rails.application.routes.url_helpers.root_url
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
