module BlogHelper
  module Caching
    def expires_in(time)
      headers['Cache-Control'] = "public, max-age=#{time}"
    end

    def no_cache
      headers['Cache-Control'] = 'no-cache'
    end
  end
end