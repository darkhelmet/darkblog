require 'feedzirra'
require 'twitter'
require 'www/delicious'
require 'hashie'

class Social
  class << self
    def repositories(username)
      resp = RestClient.get("http://github.com/api/v1/json/#{username}")
      resp = Hashie::Mash.new(Crack::JSON.parse(resp))
      resp.user.repositories.reject do |r|
        r.fork
      end.select do |r|
        rand < 0.60
      end.sort do |l,r|
        l.name <=> r.name
      end
    end

    def shared_items(id)
      url = "http://www.google.com/reader/public/atom/user/#{id}/state/com.google/broadcast"
      Feedzirra::Feed.fetch_and_parse(url).entries[0,8]
    end

    def tweets(username)
      Twitter::Search.new.from(username).to_a[0,4]
    end

    def tweet(id, username, password)
      Hashie::Mash.new(Crack::JSON.parse(RestClient.get("https://twitter.com/statuses/show/#{id}.json", 'User-Agent' => 'verbose logging http://blog.darkhax.com/', :user => username, :password => password)))
    end

    def bookmarks(username, password)
      WWW::Delicious.new(username, password).posts_recent[0,8]
    end
  end
end