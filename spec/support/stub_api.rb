require 'multi_json'

# Internal: Represents a stub of the Asana API for testing purposes. Plays
# nicely with Asana::HttpClient, being convertible to an adapter.
#
# Examples
#
#   api = StubAPI.new
#   api.on(:get, "/users/me") { |response|
#     response.status = 200 # the default
#     response.body   = { "data" => ... }
#   }
#   client = Asana::HttpClient.new(authentication: auth, adapter: api.adapter)
#   client.get("/users/me")
#   # => #<Asana::HttpClient::Response status=200 body={"data" => ...}>
#
class StubAPI
  # Internal: Represents a stubbed response.
  class Response
    attr_accessor :env, :status, :headers, :body
    def initialize(env)
      @env = env
    end

    # Public: Returns a Rack-compliant version of the response.
    def to_rack
      [
        status || 200,
        { 'Content-Type' => 'application/json' }.merge(headers || {}),
        MultiJson.dump(body)
      ]
    end
  end

  BASE_URI = Asana::HttpClient::BASE_URI
  private_constant :BASE_URI

  def initialize
    @stubs = Faraday::Adapter::Test::Stubs.new
  end

  # Public: Returns a function that takes a Faraday builder and configures it to
  # return stubbed responses.
  def to_proc
    -> builder { builder.use Faraday::Adapter::Test, @stubs }
  end
  alias_method :adapter, :to_proc

  # Public: Adds a stub for a particular method and resource_uri.
  #
  # Yields a StubAPI::Response object so that the caller can set its body, and
  # optionally its status or headers.
  #
  # Examples
  #
  #   api = StubAPI.new
  #   api.on(:get, "/users/me") { |response|
  #     response.status = 200 # the default
  #     response.body   = { "data" => ... }
  #   }
  #
  def on(method, resource_uri)
    @stubs.send(method, BASE_URI + resource_uri) do |env|
      Response.new(env).tap { |response| yield response }.to_rack
    end
  end
end
