require 'rack/abstract_middleware'
require 'packr'
require 'rainpress'

module Rack
  class StaticCache < AbstractMiddleware
    def initialize(app, options = { })
      @app = app
      @file_server = Rack::File.new(options[:root] || Dir.pwd)
      @cache_duration = options[:duration] || 365
      @compress = options[:compress] || false
    end

    def call(env)
      super(env)
      status, headers, body = @file_server.call(env)
      if 200 == status
        return @app.call(env) unless body.respond_to?(:path)
        body = compress(body, headers) if @compress
        update_headers(headers)
        [status, headers, body]
      else
        @app.call(env)
      end
    end

  protected

    def compress(body, headers)
      case ::File.extname(body.path)
      when '.css'
        pack(body, headers) do |path|
          Rainpress.compress(::File.read(path))
        end
      when '.js'
        pack(body, headers) do |path|
          Packr.pack(::File.read(path))
        end
      else
        body
      end
    end

    def pack(body, headers)
      returning([]) do |bd|
        bd << yield(body.path)
        AbstractMiddleware::update_content_length(headers, bd)
      end
    end

    def update_headers(headers)
      headers['Cache-Control'] = "max-age=#{duration_in_seconds}, public, must-revalidate"
      headers['Expires'] = duration_in_words
      %w(Etag Pragma Last-Modified).each { |key| headers.delete(key) }
    end

    def duration_in_words
      (Time.now.utc + duration_in_seconds).strftime '%a, %d %b %Y %H:%M:%S GMT'
    end

    def duration_in_seconds
      60 * 60 * 24 * @cache_duration
    end
  end
end
