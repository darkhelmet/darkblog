require 'rack/abstract_middleware'

module Rack
  class InlineCompress < AbstractMiddleware
    def initialize(app, options)
      @app = app
      @ignore = options[:ignore] || []
    end

    def call(env)
      super(env)
      return @app.call(env) if @ignore.any? { |url| path.match(url) }
      status, headers, body = @app.call(env)
      if body.is_a?(String) || body.is_a?(Array)
        doc = Hpricot(body.to_s)
        pack(doc)
        body = [doc.to_s]
        AbstractMiddleware::update_content_length(headers, body.to_s.size)
      end
      [status, headers, body]
    end

  private

    def pack(doc)
      pack_script(doc)
      pack_css(doc)
    end

    def pack_css(doc)
      elements = select(doc, 'style')
      unless elements.empty?
        elements.each do |elem|
          elem.innerHTML = Rainpress.compress(elem.innerHTML)
        end
      end
    end

    def pack_script(doc)
      elements = select(doc, 'script') { |elem| elem.attributes['src'].blank? }
      unless elements.empty?
        elements.each do |elem|
          elem.innerHTML = "//<![CDATA[\n#{Packr.pack(elem.innerHTML)}\n//]]>"
        end
      end
    end

    def select(doc, tag)
      elements = doc.search(tag)
      if block_given?
        elements.select(&Proc.new)
      else
        elements
      end
    end
  end
end