require 'rack'

class String
  # Encodes the string for use in a URL
  #
  # @return [String] The string escaped for URL usage
  def url_encode
    Rack::Utils.escape(self)
  end

  def matches_any_of?(*args)
    args.any? { |a| self.match(a) }
  end
end

class Float
  # For the cache bullshit
  def tv_sec
    to_i
  end
end