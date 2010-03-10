require 'rack/abstract_middleware'

module Rack
  class Insert < AbstractMiddleware
    def initialize(app, options = { })
      @app = app
      @regex = {
        :body => /<\/body>/,
        :head => /<\/head>/
      }[options[:where] || :body]
      @ignore = options[:ignore] || []
      @html = yield
    end

    def call(env)
      super(env)
      return @app.call(env) if @ignore.any? { |url| path.match(url) }
      status, headers, body = @app.call(env)
      if html?(headers)
        body.each do |part|
          if part =~ @regex
            part.sub!(@regex, "#{@html}\\1")
            break
          end
        end
        AbstractMiddleware::update_content_length(headers, body)
      end
      [status, headers, body]
    end
  end

private

  def get_regex

  end
end