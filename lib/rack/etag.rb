require 'digest/md5'

module Rack
  class ETag
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      if body.is_a?(String) || body.is_a?(Array)
        if !headers.has_key?('ETag')
          val = body.nil? ? nil : body.to_s
          headers['ETag'] = Digest::MD5.hexdigest(val) unless val.nil?
        end
      end
      [status, headers, body]
    end
  end
end
