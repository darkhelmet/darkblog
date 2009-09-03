require 'sinatra/base'

module Sinatra
  module NamedRoutes
    def named_route(verb, name, options = {}, &blk)
      send(verb, named_routes[name], options, &blk)
    end
    
    def named_routes
      @named_routes ||= {}
    end
  end
  
  register NamedRoutes
end