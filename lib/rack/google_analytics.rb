require 'rack/abstract_middleware'

module Rack
  class GoogleAnalytics < AbstractMiddleware
    TRACKING_CODE = <<-EOCODE
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("{{ID}}");
pageTracker._trackPageview();
} catch(err) {}</script>
EOCODE

    def initialize(app, id, options = { })
      @app = app
      @id = id
      @ignore = options[:ignore] || []
    end

    def call(env)
      super(env)
      return @app.call(env) if @ignore.any? { |url| path.match(url) }
      status, headers, body = @app.call(env)
      if html?(headers)
        body.each do |part|
          if part =~ /<\/body>/
            part.sub!(/<\/body>/, "#{tracking_code}</body>")
            break
          end
        end
        AbstractMiddleware::update_content_length(headers, body)
      end
      [status, headers, body]
    end

  private

    def tracking_code
      TRACKING_CODE.sub(/\{\{ID\}\}/, @id)
    end
  end
end
