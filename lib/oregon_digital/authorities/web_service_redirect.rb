# frozen_string_literal: true

module OregonDigital::Authorities
  ##
  # Mix-in to enable broader redirect following.
  module WebServiceRedirect
    ##
    # Make a web request and retrieve the response,
    # following more redirects than Qa::Authorities::WebServiceBase
    #
    # @param url [String]
    # @return [Faraday::Response]
    def response(url)
      connection = Faraday.new(url) do |b|
        b.use FaradayMiddleware::FollowRedirects, limit: 5
        b.adapter :net_http
      end
      connection.get { |req| req.headers['Accept'] = 'application/json' }
    end
  end
end
