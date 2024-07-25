# frozen_string_literal: true

module OregonDigital
  # create urls needed to point to asset show pages and representative images
  module UriMethods
    def iiif_url(pid)
      "https://iiif.oregondigital.org/iiif/#{bucket_path(pid)}-jp2.jp2/full/430,/0/default.jpg"
    end

    def bucket_path(pid)
      pid.gsub(/(.{2})/, '\1/')
    end

    def iiif_doc_url(pid)
      "https://iiif.oregondigital.org/iiif/#{bucket_path(pid)}-jp2-0000.jp2/full/430,/0/default.jpg"
    end

    def show_url(klass, pid)
      "https://oregondigital.org/concern/#{klass}/#{pid}"
    end

    def video_thumb(pid)
      doc = Hyrax::SolrService.query("id:#{pid}", rows: 1).first
      "https://oregondigital.org#{doc['thumbnail_path_ss']}"
    end

    def assign_uris(item)
      @asset_show_uri = show_url(item.class.to_s.downcase + 's', item.id)
      return image_uri(item) unless item.class.to_s == 'Generic'

      return if item.member_ids.blank?

      image_uri(query(item.member_ids.first))
    end

    def query(pid)
      Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: pid)
    end

    def image_uri(item)
      return if item.member_ids.blank?

      case item.class.to_s
      when 'Image'
        @asset_image_uri = iiif_url(item.member_ids.first.to_s)
      when 'Document'
        @asset_image_uri = iiif_doc_url(item.member_ids.first.to_s)
      when 'Video'
        @asset_image_uri = video_thumb(item.member_ids.first.to_s)
      end
    end
  end
end
