module Rack
  class AbstractMiddleware
    def call(env)
      @env = env
    end

  protected

    def path
      Rack::Utils.unescape(@env['PATH_INFO'])
    end
  end
end