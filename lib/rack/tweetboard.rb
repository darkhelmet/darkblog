module Rack
  class Tweetboard < AbstractMiddleware
    def initialize(app, username, options = {})
      @app = app
      @username = username
      @ignore = options[:ignore] || []
    end

    def call(env)
      super(env)
      status, headers, body = @app.call(env)
      unless @ignore.any? { |url| env['PATH_INFO'].match(url) }
        body.each do |part|
          if part =~ /<\/body>/
            part.sub!(/<\/body>/, "#{code}</body>")
            break
          end
        end
      end
      AbstractMiddleware::update_content_length(headers, body)
      [status, headers, body]
    end

  private

    def code
      @code ||= %Q{<script type='text/javascript' src='http://tweetboard.com/#{@username}/tb.js'></script>}
    end
  end
end