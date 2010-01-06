module Rack
  class AbstractMiddleware
  protected

    def path
      Rack::Utils.unescape(env['PATH_INFO'])
    end
  end
end