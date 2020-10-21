# frozen_string_literal: true
module OregonDigital
  module Actors
    # If there is a key `:remote_files' in the attributes, it attaches the files at the specified URIs
    # to the work. e.g.:
    #     attributes[:remote_files] = filenames.map do |name|
    #       { url: "https://example.com/file/#{name}", file_name: name }
    #     end
    #
    # Browse everything may also return a local file. And although it's in the
    # url property, it may have spaces, and not be a valid URI.
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

      # @param [HashWithIndifferentAccess] remote_files
      # @return [TrueClass]
      def attach_files(env, remote_files)
        return true unless remote_files
        remote_files.each do |url|
          next if url.blank?
          # Escape any space characters, so that this is a legal URI
          uri = URI.parse(Addressable::URI.escape(url))
          create_file_from_url(env, uri)
        end
        true
      end

      # Generic utility for creating FileSet from a URL
      # Used in to import files using URLs from a file picker like browse_everything
      def create_file_from_url(env, uri)
        import_url = URI.decode_www_form_component(uri.to_s)
        resource = OEmbed::Providers.get(import_url)
        ::FileSet.new(import_url: import_url, label: resource.title) do |fs|
          fs.oembed_url = import_url
          actor = Hyrax::Actors::FileSetActor.new(fs, env.user)
          actor.create_metadata(visibility: env.curation_concern.visibility)
          actor.attach_to_work(env.curation_concern)
          Rails.logger.info '!!!FS SAVING!!!'
          fs.save!
          IngestLocalFileJob.perform_later(fs, '/data/app/assets/images/dummy.png', env.user)
        end
      end

      def operation_for(user:)
        Hyrax::Operation.create!(user: user,
                                 operation_type: "Attach Remote File")
      end
    end
  end
end
