module Sinatra
  class RouteNotFound < RuntimeError; end

  module Routing
    class NamedRoute
      # Constructs the NamedRoute which accepts the application and
      # the route alias names to register (i.e [:account] or [:admin, :show])
      # NamedRoute.new(@app, :admin, :show)
      def initialize(app, *names)
        @app = app
        @names = names.flatten
      end

      # Used to define the url mapping to the supplied alias
      # NamedRoute.new(@app, :account).to('/account/path')
      def to(path)
        @app.named_paths[@names.unshift(@app.app_name)] = path
      end

      # Used to define the url mappings for child aliases within a namespace
      # Invokes map on the application itself, appending the namespace to the route
      # NamedRoute.new(@app, :admin).map(:show).to('/admin/show')
      # is equivalent to NamedRoute.new(@app, :admin, :show).to('/admin/show')
      def map(*args, &block)
        @app.map(*args.unshift(@names), &block)
      end
    end

    module RoutingHelpers
      # Used to retrieve the full url for a given named route alias from the named_paths data
      # Accepts parameters which will be substituted into the url if necessary
      # url_for(:accounts) => '/accounts'
      # url_for(:account, :id => 5) => '/account/5'
      # url_for(:admin, show, :id => 5, :name => "demo") => '/admin/path/5/demo'
      def url_for(*route_name)
        values = route_name.extract_options!
        mapped_url = self.class.named_paths[route_name] || self.class.named_paths[route_name.dup.unshift(self.class.app_name)]
        raise Sinatra::RouteNotFound.new("Route alias #{route_name.inspect} is not mapped to a url") unless mapped_url
        result_url = String.new(File.join(self.class.uri_root, mapped_url))
        result_url.scan(%r{/?(:\S+?)(?:/|$)}).each do |placeholder|
          value_key = placeholder[0][1..-1].to_sym
          result_url.gsub!(Regexp.new(placeholder[0]), values[value_key].to_s)
        end
        result_url
      end
    end

    def self.registered(app)
      # Named paths stores the named route aliases mapping to the url
      # i.e { [:account] => '/account/path', [:admin, :show] => '/admin/show/:id' }
      app.set(:named_paths, {})
      app.set(:app_name, app.name.underscore.to_sym) unless app.respond_to?(:app_name)
      app.set(:uri_root, '/') unless app.respond_to?(:uri_root)
      app.helpers(Sinatra::Routing::RoutingHelpers)
    end

    # map constructs a mapping between a named route and a specified alias
    # the mapping url can contain url query parameters
    # map(:accounts).to('/accounts/url')
    # map(:admin, :show).to('/admin/show/:id')
    # map(:admin) { |namespace| namespace.map(:show).to('/admin/show/:id') }
    def map(*args, &block)
      named_router = Sinatra::Routing::NamedRoute.new(self, *args)
      block_given? ? block.call(named_router) : named_router
    end

    # Used to define namespaced route configurations in order to group similar routes
    # Class evals the routes but with the namespace assigned which will append to each route
    # namespace(:admin) { get(:show) { "..." } }
    def namespace(name, &block)
      original, @_namespace = @_namespace, name
      self.class_eval(&block)
      @_namespace = original
    end

    # Hijacking route method in sinatra to replace a route alias (i.e :account) with the full url string mapping
    # Supports namespaces by accessing the instance variable and appending this to the route alias name
    # If the path is not a symbol, nothing is changed and the original route method is invoked
    def route(verb, path, options={}, &block)
      if path.kind_of?(Symbol)
        route_name = [self.app_name, @_namespace, path].flatten.compact
        path = named_paths[route_name]
        raise RouteNotFound.new("Route alias #{route_name.inspect} is not mapped to a url") unless path
      end
      super(verb, path, options, &block)
    end
  end

  register Routing
end