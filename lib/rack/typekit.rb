require 'rack/abstract_middleware'

module Rack
  class Typekit < AbstractMiddleware
    TYPEKIT_CODE = <<-EOCODE
<script type="text/javascript" src="http://use.typekit.com/{{ID}}.js"></script>
<script type="text/javascript">try{Typekit.load();}catch(e){}</script>
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
          if part =~ /<\/head>/
            part.sub!(/<\/head>/, "#{typekit_code}</head>")
            break
          end
        end
        AbstractMiddleware::update_content_length(headers, body)
      end
      [status, headers, body]
    end

  private

    def typekit_code
      TYPEKIT_CODE.sub(/\{\{ID\}\}/, @id)
    end
  end
end
