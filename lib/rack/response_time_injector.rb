module Rack
  class ResponseTimeInjector
    def initialize(app, options = {})
      @app = app
      @format = options[:format] || '%f'
    end

    def call(env)
      t0 = Time.now
      status, headers, body = @app.call(env)
      if body.is_a?(String) || body.is_a?(Array)
        body = [body].flatten
        body.each do |part|
          part.gsub!('{{responsetime}}') do
            diff = Time.now - t0
            if @format.respond_to? :call
              @format.call(diff)
            else
              @format % diff
            end
          end
        end
        if headers['Content-Length']
          headers['Content-Length'] = body.to_s.length.to_s
        end
      end
      [status, headers, body]
    end
  end
end