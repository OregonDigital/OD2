# frozen_string_literal: true

# This is a list of models which are "fake" (root, <blob>) or else contained
# within / otherwise tied to their assets, so they aren't stored in the
# FedoraFinder's assets / containers lists.  We explicitly list these so we can
# easily see if a model is present which we haven't accounted for.
IGNORED_MODELS = [
  'root',
  '<blob>',
  'Hydra::AccessControls::Permission',
  'Hydra::AccessControls::Embargo',
  'Hydra::AccessControls::Lease',
  'Hydra::AccessControl',
  'ActiveFedora::Aggregation::Proxy',
  'ActiveFedora::Aggregation::ListSource',
  'ActiveFedora::IndirectContainer',
  'ActiveFedora::DirectContainer'
].freeze
COLLECTION_MODELS = %w[Collection AdminSet].freeze
ASSET_MODELS = %w[Document Image Audio Generic Video FileSet].freeze
ALL_MODELS = [IGNORED_MODELS + COLLECTION_MODELS + ASSET_MODELS].flatten.freeze

module OregonDigital
  # FedoraObject holds some basic data pulled / parsed from Fedora's raw data
  class FedoraObject
    attr_accessor :pid, :path, :parent, :raw, :model, :contains,
                  :contains_pids, :access_control, :access_control_pids, :proxy_for,
                  :proxy_for_pids, :proxies, :proxy_pids

    def initialize(parent:, path:)
      set_defaults
      self.parent = parent
      self.path = path.sub(%r{^/}, '')

      if self.path.empty?
        self.pid = ''
        self.path = 'root'
        self.model = 'root'
      else
        self.pid = ActiveFedora::Base.uri_to_id(path)
      end
    end

    def parse(raw)
      self.raw = raw
      return if raw.nil?

      parse_contains
      parse_model
      parse_access_control
      parse_proxy_for
    end

    # write dumps the raw data we've read from Fedora
    def write
      pathinfo = ['objects'] + path.split('/')
      filename = pathinfo.pop + '.json'
      dir = pathinfo.join('/')
      FileUtils.mkpath(dir)
      File.open("#{dir}/#{filename}", 'w') { |f| f.puts JSON.dump(raw) }
    end

    private

    def set_defaults
      self.contains = []
      self.contains_pids = []
      self.access_control = []
      self.access_control_pids = []
      self.proxies = []
      self.proxy_pids = []
      self.raw = ''
      self.model = ''
    end

    def parse_contains
      self.contains = raw['http://www.w3.org/ns/ldp#contains'] || []
      self.contains_pids = array_to_pids(contains)
    end

    def parse_access_control
      self.access_control = raw['http://www.w3.org/ns/auth/acl#accessControl'] || []
      self.access_control_pids = array_to_pids(access_control)
    end

    def parse_proxy_for
      self.proxy_for = raw['http://www.openarchives.org/ore/terms/proxyFor'] || []
      self.proxy_for_pids = array_to_pids(proxy_for)
    end

    def array_to_pids(a)
      a.collect { |data| ActiveFedora::Base.uri_to_id(data['@id']) }
    end

    def parse_model
      models = raw['info:fedora/fedora-system:def/model#hasModel'] || []

      # This really shouldn't be possible, so it's a hard crash
      raise "Too many models for pid #{pid}, path #{path}" if models.length > 1

      self.model = models[0]['@value'] unless models.length.zero?
    end
  end

  # FedoraFinder finds all Fedora objects starting at a given Base URL
  # (typically the root URL of the Fedora service) and stores them in memory
  class FedoraFinder
    attr_reader :all_objects, :by_pid, :collections, :assets

    def initialize(base_url)
      @base_url = base_url
      @all_objects = []
      @collections = []
      @assets = []
      @by_pid = {}
    end

    # fetch_all returns all objects fetched from Fedora which are meaningful
    # in any way (ignored model types will be returned, but their children
    # will not)
    def fetch_all
      request_objects(url: @base_url)
      setup_proxies
    end

    private

    def request_objects(url:, parent: nil)
      object = FedoraObject.new(parent: parent, path: url.sub(@base_url, ''))
      object.parse(get(url)[0])

      categorize(object)
      crawl(object)
    end

    # Stores the object data in our full object list as well as any other lists
    # where it makes sense, and keys it by its pid
    #
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def categorize(object)
      by_pid[object.pid] = object
      all_objects << object

      m = object.model
      return if IGNORED_MODELS.include?(m)

      if COLLECTION_MODELS.include?(m)
        puts "Read collection #{object.pid}"
        collections << object
      end

      if ASSET_MODELS.include?(m)
        puts "Read asset #{object.pid}"
        assets << object
      end

      raise "object #{object.pid} has unknown model (#{m})" unless ALL_MODELS.include?(m)
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def crawl(object)
      object.contains.each do |child|
        request_objects(url: child['@id'], parent: object)
      end
    end

    def get(url)
      # I like that Fedora 4 has a way to specify a limit, but... not an offset.
      resp = Faraday.get(url, {}, 'Accept' => 'application/ld+json', 'Limit' => '-1')

      # A 200 means all's well, but we also have to check 406 responses,
      # because that means the requested content type (JSON) is not available.
      # That seems to be the response for things like binary blobs, where we
      # wouldn't have any metadata to parse anyway, so we just give those a
      # fake model and nothing else.
      case resp.status
      when 200 then return JSON.parse resp.body
      when 406 then return [{ 'info:fedora/fedora-system:def/model#hasModel' => [{ '@value' => '<blob>' }] }]
      else          raise "Unable to fetch #{url.inspect}: #{resp.inspect}"
      end
    end

    # Sets up objects to know about anything which acts as their proxy.  Proxy
    # objects need to be indexed after the object for which they are a proxy.
    # Proxies seem to have multiple meanings, such as relating an object to its
    # fileset(s) or very indirectly relating a collection to its assets.
    def setup_proxies
      all_objects.each do |obj|
        next unless obj.model == 'ActiveFedora::Aggregation::Proxy'

        obj.proxy_for_pids.each do |pid|
          by_pid[pid].proxies << obj
          by_pid[pid].proxy_pids << obj.pid
        end
      end
    end
  end
end
