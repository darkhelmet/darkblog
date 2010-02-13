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

module Sinatra
  module MarkupPlugin
    module AssetTagHelpers
      def image_tag(url, options={})
        src = image_path(url)
        disk_path = File.join('public', src)
        src += "?#{File.mtime(disk_path).to_i}" if File.exists?(disk_path)
        options.reverse_merge!(:src => src)
        tag(:img, options)
      end
    end
  end
end