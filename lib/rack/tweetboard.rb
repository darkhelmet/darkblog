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
      if html?(headers)
        body.each do |part|
          if part =~ /<\/body>/
            part.sub!(/<\/body>/, "#{code}</body>")
            break
          end
        end
        AbstractMiddleware::update_content_length(headers, body)
      end
      [status, headers, body]
    end

  private

    def code
      @code ||= %Q{<script type='text/javascript' src='http://tweetboard.com/#{@username}/tb.js'></script>}
    end
  end
end