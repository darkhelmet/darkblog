require 'digest/md5'

module Rack
  # Automatically sets the ETag header on all String bodies
  class ETag
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      if !headers.has_key?('ETag')
        val = case body
              when String
                body
              when Array
                f = body.first
                f.is_a?(String) ? f : nil
              else
                nil
              end
        headers['ETag'] = %("#{Digest::MD5.hexdigest(val)}") unless val.nil?
      end
      [status, headers, body]
    end
  end
end
