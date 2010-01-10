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
  end
end