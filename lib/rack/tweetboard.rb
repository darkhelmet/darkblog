module Rack
  class Tweetboard
    def initialize(app, username, options = {})
      @app = app
      @username = username
      @ignore = options[:ignore] || []
    end

    def call(env)
      status, headers, body = @app.call(env)
      if (body.is_a?(String) || body.is_a?(Array)) && !@ignore.any? { |url| env['PATH_INFO'].match(url) }
        body = [body].flatten
        body.each do |part|
          if part =~ /<\/body>/
            part.sub!(/<\/body>/, "#{code}</body>")
            if headers['Content-Length']
              headers['Content-Length'] = body.to_s.size.to_s
            end
            break
          end
        end
      end
      [status, headers, body]
    end

  private

    def code
      @code ||= %Q{<script type='text/javascript' src='http://tweetboard.com/#{@username}/tb.js'></script>}
    end
  end
end