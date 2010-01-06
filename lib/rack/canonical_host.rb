module Rack
  class CanonicalHost
    def initialize(app, host=nil, &block)
      @app = app
      @host = (block_given? && block.call) || host
    end

    def call(env)
      if url = url(env)
        [301, { 'Location' => url, 'Content-Type' => 'text/html' }, ['Redirecting...']]
      else
        @app.call(env)
      end
    end

  private

    def url(env)
      if @host && env['SERVER_NAME'] != @host
        url = Rack::Request.new(env).url
        url.sub(%r{\A(https?://)(.*?)(:\d+)?(/|$)}, "\\1#{@host}\\3/")
      end
    end
  end
end