module Rack
  class AbstractMiddleware
    def call(env)
      @env = env
    end

  protected

    class << self
      def update_content_length(headers, length)
        if headers['Content-Length']
          headers['Content-Length'] = length.to_s
        end
      end
    end

    def path
      Rack::Utils.unescape(@env['PATH_INFO'])
    end

    def host
      @env['HTTP_HOST']
    end

    def protocol
      @env['rack.url_scheme']
    end
  end
end