module Rack
  class InlineCompress
    def initialize(app, options)
      @app = app
      @ignore = options[:ignore]
    end

    def call(env)
      path = env['REQUEST_PATH'] || env['PATH_INFO']
      return @app.call(env) if @ignore.any? { |url| path.match(url) }
      status, headers, body = @app.call(env)
      if body.is_a?(String) || body.is_a?(Array)
        doc = Hpricot(body.to_s)
        elements = doc.search('script').reject do |elem|
          elem.attributes.has_key?('src')
        end
        unless elements.empty?
          elements.each { |elem| elem.innerHTML = "//<![CDATA[\n#{Packr.pack(elem.innerHTML)}\n//]]>" }
        end
        elements = doc.search('style')
        unless elements.empty?
          elements.each { |elem| elem.innerHTML = Rainpress.compress(elem.innerHTML) }
        end
        body = [doc.to_s]
        if headers['Content-Length']
          headers['Content-Length'] = body.to_s.size.to_s
        end
      end
      [status, headers, body]
    end
  end
end