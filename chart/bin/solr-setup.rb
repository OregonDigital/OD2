# !/usr/bin/env ruby
# frozen_string_literal: true

puts 'Installing ZK and Zookeper gems'
system('CFLAGS=-Wno-error=format-overflow gem install zookeeper --version 1.4.11')
system('CFLAGS=-Wno-error=format-overflow gem install zk')

# Create a new Solr collection
class CreateSolrCollection
  require 'faraday'
  require 'json'

  def initialize(name)
    @name = name
  end

  def create_solr_collection
    return if collection_exists?
    response = Faraday.get collections_url, collection_options
    return response.status
  end

  private

  def collections_url
    "#{ENV.fetch('SOLR_BASE_URL')}/admin/collections"
  end

  def collection_options
    {
      'collection.configName' => @name,
      'numShards' => 1,
      action: 'CREATE',
      name: @name
    }
  end

  def collection_exists?
    response = Faraday.get collections_url, action: 'LIST'
    collections = JSON.parse(response.body)['collections']
    collections.include? @name
  end
end

# Upload solr configuration from the local filesystem into the zookeeper configs path for solr
class SolrConfigUploader
  attr_reader :collection_path
  require 'zk'
  ##
  # Build a new SolrConfigUploader using the application-wide settings
  def self.default
    new(ENV.fetch('SOLR_CONFIGSET'))
  end

  def initialize(collection_path)
    @collection_path = collection_path
  end

  def upload(upload_directory)
    with_client do |zk|
      salient_files(upload_directory).each do |file|
        zk.create(zookeeper_path_for_file(file), file.read, or: :set)
      end
    end
  end

  def get(path)
    with_client do |zk|
      zk.get(zookeeper_path(path)).first
    end
  end

  private

  def zookeeper_path_for_file(file)
    zookeeper_path(File.basename(file.path))
  end

  def zookeeper_path(*path)
    "/#{([collection_path] + path).compact.join('/')}"
  end

  def salient_files(config_dir)
    return to_enum(:salient_files, config_dir) unless block_given?

    Dir.new(config_dir).each do |file_name|
      full_path = File.expand_path(file_name, config_dir)

      next unless File.file? full_path

      yield File.new(full_path)
    end
  end

  def with_client(&block)
    ensure_chroot!
    ::ZK.open(connection_str, &block)
  end

  def connection_str
    "#{ENV.fetch('ZOOKEEPER_ENDPOINT')}/configs"
  end

  def ensure_chroot!
    raise ArgumentError, 'Zookeeper connection string must include a chroot path' unless connection_str =~ %r{/[^/]}
  end
end

puts 'Loading the Solr Config to Zookeeper'
SolrConfigUploader.default.upload(ENV.fetch('SOLR_CONFIGSET_SOURCE_PATH'))

puts 'Creating the Solr Collection'
puts CreateSolrCollection.new(ENV.fetch('SOLR_CONFIGSET')).create_solr_collection

