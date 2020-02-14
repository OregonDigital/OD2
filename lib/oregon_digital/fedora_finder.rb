# frozen_string_literal: true

module OregonDigital
  # FedoraObject holds some basic data pulled / parsed from Fedora's raw data
  class FedoraObject
    attr_accessor :pid, :path, :parent, :raw, :model, :contains,
                  :contains_pids, :access_control, :access_control_pids, :proxy_for,
                  :proxy_for_pids

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
      self.raw = ''
      self.model = ''
    end

    def parse_contains
      self.contains = raw['http://www.w3.org/ns/ldp#contains'] || []
      self.contains_pids = contains.collect { |data| ActiveFedora::Base.uri_to_id(data['@id']) }
    end

    def parse_access_control
      self.access_control = raw['http://www.w3.org/ns/auth/acl#accessControl'] || []
      self.access_control_pids = access_control.collect { |data| ActiveFedora::Base.uri_to_id(data['@id']) }
    end

    def parse_proxy_for
      self.proxy_for = raw['http://www.openarchives.org/ore/terms/proxyFor'] || []
      self.proxy_for_pids = proxy_for.collect { |data| ActiveFedora::Base.uri_to_id(data['@id']) }
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
    def initialize(base_url)
      @base_url = base_url
      @objects = []
    end

    # fetch_all returns all objects fetched from Fedora which are meaningful
    # in any way (ignored model types will be returned, but their children
    # will not)
    def fetch_all
      request_objects(url: @base_url)
      @objects
    end

    private

    def request_objects(url:, parent: nil)
      object = FedoraObject.new(parent: parent, path: url.sub(@base_url, ''))
      object.parse(get(url)[0])

      @objects << object

      crawl(object)
    end

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
      # wouldn't have any metadata to parse anyway, so we just skip those.
      case resp.status
      when 200 then return JSON.parse resp.body
      when 406 then return [nil]
      else          raise "Unable to fetch #{url.inspect}: #{resp.inspect}"
      end
    end
  end
end
