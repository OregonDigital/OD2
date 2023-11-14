# frozen_string_literal: true

module OregonDigital
  module Actors
    # If there is a key `:oembed_urls' in the attributes, it extracts the URLs, creates a fileset, addes the URL as metadata, and attaches a dummy image
    # to the work.
    class CreateWithOembedUrlActor < Hyrax::Actors::AbstractActor
      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if create was successful
      def create(env)
        oembed_urls = env.attributes.delete(:oembed_urls)
        next_actor.create(env) && attach_files(env, oembed_urls)
      end

      # @param [Hyrax::Actors::Environment] env
      # @return [Boolean] true if update was successful
      def update(env)
        oembed_urls = env.attributes.delete(:oembed_urls)
        next_actor.update(env) && attach_files(env, oembed_urls)
      end

      private

      # @param [HashWithIndifferentAccess] oembed_urls
      # @return [TrueClass]
      def attach_files(env, oembed_urls)
        return true unless oembed_urls

        oembed_urls.each do |url|
          next if url.blank?

          # Escape any space characters, so that this is a legal URI
          uri = URI.parse(Addressable::URI.escape(url.strip))
          create_file_from_url(env, uri)
        end
        true
      end

      # Utility for creating FileSet from an oEmbed URL
      # Used to create a FileSet with a dummy image and store the url into a metadata field
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def create_file_from_url(env, uri)
        oembed_url = URI.decode_www_form_component(uri.to_s)
        use_valkyrie = false

        file_set = ::FileSet.new(oembed_url: oembed_url) do |fs|
          title = 'oEmbed Media'
          begin
            resource = OEmbed::Providers.get(oembed_url)
            title = resource.respond_to?(:title) ? resource.title : "oEmbed Media from #{resource.provider_name}"
          rescue OEmbed::Error => e
            msg = e.message
            msg += ' (broken or non-allowlisted URI)' if e.is_a? OEmbed::NotFound
            OembedError.find_or_create_by(document_id: fs.id) do |error|
              error.document_id = fs.id
            end.add_error(msg)
          end
          fs.title = Array(title)
        end

        if curation_concern.is_a? Valkyrie::Resource
          file_set = Hyrax.persister.save(resource: file_set)
          use_valkyrie = true
        end

        actor = Hyrax::Actors::FileSetActor.new(fs, env.user, use_valkyrie: use_valkyrie)
        actor.create_metadata(visibility: env.curation_concern.visibility)
        actor.attach_to_work(env.curation_concern)
        file_set.save! if file_set.respond_to?(:save!)
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength
    end
  end
end
