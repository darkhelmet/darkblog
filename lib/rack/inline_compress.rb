require 'rack/abstract_middleware'
require 'packr'
require 'rainpress'

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
      body.map! do |part|
        returning(Hpricot(part)) do |doc|
          pack(doc)
        end.to_s
      end
      AbstractMiddleware::update_content_length(headers, body)
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