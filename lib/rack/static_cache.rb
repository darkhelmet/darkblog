require 'rack/abstract_middleware'
require 'packr'
require 'rainpress'

module Rack
  class StaticCache < AbstractMiddleware
    def initialize(app, options = { })
      @app = app
      @urls = options[:urls]
      @file_server = Rack::File.new(options[:root] || Dir.pwd)
      @cache_duration = options[:duration] || 1
      @compress = options[:compress] || false
    end

    def call(env)
      super(env)
      if @urls.any? { |url| path.match(url) }
        status, headers, body = @file_server.call(env)
        return @app.call(env) unless body.respond_to?(:path)
        update_headers(headers)
        if @compress
          body = compress(body, headers)
        end
        [status, headers, body]
      else
        @app.call(env)
      end
    end

  protected

    def compress(body, headers)
      case ::File.extname(body.path)
      when '.css'
        pack(headers, body) do |path|
          Rainpress.compress(::File.read(path))
        end
      when '.js'
        pack(headers, body) do |path|
          Packr.pack(::File.read(path))
        end
      else
        body
      end
    end

    def pack(headers, body)
      returning([]) do |bd|
        bd << yield(body.path)
        AbstractMiddleware::update_content_length(headers, bd)
      end
    end

    def update_headers(headers)
      headers['Cache-Control'] = "max-age=#{duration_in_seconds}, public"
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
