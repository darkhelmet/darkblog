require 'digest/md5'

module Rack
  # Automatically sets the ETag header on all String bodies
  class ETag
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      if 'GET' == env['REQUEST_METHOD'] && !headers.has_key?('ETag')
        val = body.nil? ? nil : body.to_s
        headers['ETag'] = %("#{Digest::MD5.hexdigest(val)}") unless val.nil?
      end
      [status, headers, body]
    end
  end
end
