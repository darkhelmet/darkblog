module Rack
  class RemoveSlash
    def initialize(app)
      @app = app
    end
    
    def call(env)
      path = env['REQUEST_PATH']
      if '/' != path
        if '/' == path[-1,1]
          while '/' == path.chop![-1,1]; end
          return [301, { 'Location' => "#{protocol(env)}://#{host(env)}#{path}", 'Content-Type' => 'text/html' }, 'A trailing slash? Really?']
        end
      end
      @app.call(env)
    end
    
  private
  
    def host(env)
      env['HTTP_HOST']
    end
    
    def protocol(env)
      env['rack.url_scheme']
    end
  end
end