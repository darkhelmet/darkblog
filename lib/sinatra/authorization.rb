module Sinatra
  module Authorization
    module Helpers
      def auth
        @auth ||= Rack::Auth::Basic::Request.new(request.env)
      end

      def unauthorized!(realm = 'myApp.com')
        headers['WWW-Authenticate'] = %(Basic realm="#{realm}")
        throw :halt, [ 401, 'Authorization Required' ]
      end

      def bad_request!
        throw :halt, [ 400, 'Bad Request' ]
      end

      def authorized?
        request.env['REMOTE_USER']
      end

      def authorize(username, password)
        Blog.username == username && Blog.password == password
      end

      def require_administrative_privileges
        return if authorized?
        unauthorized! unless auth.provided?
        bad_request! unless auth.basic?
        unauthorized! unless authorize(*auth.credentials)
        request.env['REMOTE_USER'] = auth.username
      end

      def admin?
        authorized?
      end
    end

    def self.registered(app)
      app.helpers(Helpers)
    end
  end

  register(Authorization)
end