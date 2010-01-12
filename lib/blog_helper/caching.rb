module BlogHelper
  module Caching
    def no_cache
      headers['Cache-Control'] = 'no-cache'
    end
  end
end