class Darkblog < Sinatra::Base
  module Caching
    def no_cache
      headers['Cache-Control'] = 'no-cache'
    end
  end

  helpers(Caching)
end