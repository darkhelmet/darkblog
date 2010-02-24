require 'rack/abstract_middleware'

module Rack
  class Insert < AbstractMiddleware
    def initialize(app, options = { })
      @app = app
      @ignore = options[:ignore] || []
      @html = yield
    end

    def call(env)
      super(env)
      return @app.call(env) if @ignore.any? { |url| path.match(url) }
      status, headers, body = @app.call(env)
      if html?(headers)
        body.each do |part|
          if part =~ /<\/body>/
            part.sub!(/<\/body>/, "#{@html}</body>")
            break
          end
        end
        AbstractMiddleware::update_content_length(headers, body)
      end
      [status, headers, body]
    end
  end
end