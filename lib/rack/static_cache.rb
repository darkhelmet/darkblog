require 'rack/abstract_middleware'

module Rack

  #
  # The Rack::StaticCache middleware automatically adds, removes and modifies
  # stuffs in response headers to facilitiate client and proxy caching for static files
  # that minimizes http requests and improves overall load times for second time visitors.
  #
  # Once a static content is stored in a client/proxy the only way to enforce the browser
  # to fetch the latest content and ignore the cache is to rename the static file.
  #
  # Alternatively, we can add a version number into the URL to the content to bypass
  # the caches. Rack::StaticCache by default handles version numbers in the filename.
  # As an example,
  # http://yoursite.com/images/test-1.0.0.png and http://yoursite.com/images/test-2.0.0.png
  # both reffers to the same image file http://yoursite.com/images/test.png
  #
  # Another way to bypass the cache is adding the version number in a field-value pair in the
  # URL query string. As an example, http://yoursite.com/images/test.png?v=1.0.0
  # In that case, set the option :versioning to false to avoid unneccessary regexp calculations.
  #
  # It's better to keep the current version number in some config file and use it in every static
  # content's URL. So each time we modify our static contents, we just have to change the version
  # number to enforce the browser to fetch the latest content.
  #
  # You can use Rack::Deflater along with Rack::StaticCache for further improvements in page loading time.
  #
  # Examples:
  #     use Rack::StaticCache, :urls => ["/images", "/css", "/js", "/documents*"], :root => "statics"
  #     will serve all requests beginning with /images, /csss or /js from the
  #     directory "statics/images",  "statics/css",  "statics/js".
  #     All the files from these directories will have modified headers to enable client/proxy caching,
  #     except the files from the directory "documents". Append a * (star) at the end of the pattern
  #     if you want to disable caching for any pattern . In that case, plain static contents will be served with
  #     default headers.
  #
  #     use Rack::StaticCache, :urls => ["/images"], :duration => 2, :versioning => false
  #     will serve all requests begining with /images under the current directory (default for the option :root
  #     is current directory). All the contents served will have cache expiration duration set to 2 years in headers
  #     (default for :duration is 1 year), and StaticCache will not compute any versioning logics (default for
  #     :versioning is true)
  #


  class StaticCache < AbstractMiddleware
    def initialize(app, options = { })
      @app = app
      @urls = options[:urls]
      @file_server = Rack::File.new(options[:root] || Dir.pwd)
      @cache_duration = options[:duration] || 1
      @compress = options[:compress] || false
    end

    def call(env)
      super(env)
      if @urls.any? { |url| path.match(url) }
        status, headers, body = @file_server.call(env)
        return @app.call(env) unless body.respond_to?(:path)
        update_headers(headers)
        if @compress
          body = compress(body, headers)
        end
        [status, headers, body]
      else
        @app.call(env)
      end
    end

  protected

    def compress(body, headers)
      case ::File.extname(body.path)
      when '.css'
        pack(headers, body) do |path|
          Rainpress.compress(::File.read(path))
        end
      when '.js'
        pack(headers, body) do |path|
          Packr.pack(::File.read(path), :shrink_vars => true)
        end
      else
        body
      end
    end

    def pack(headers, body)
      returning([]) do |bd|
        bd << yield(body.path)
        AbstractMiddleware::update_content_length(headers, bd.to_s.size)
      end
    end

    def update_headers(headers)
      headers['Cache-Control'] = "max-age=#{duration_in_seconds}, public"
      headers['Expires'] = duration_in_words
      %w(Etag Pragma Last-Modified).each { |key| headers.delete(key) }
    end

    def duration_in_words
      (Time.now.utc + duration_in_seconds).strftime '%a, %d %b %Y %H:%M:%S GMT'
    end

    def duration_in_seconds
      60 * 60 * 24 * @cache_duration
    end
  end
end
