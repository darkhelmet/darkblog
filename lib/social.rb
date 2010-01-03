require 'feedzirra'
require 'twitter'
require 'hashie'

# Helper class to get certain social web things, like Delicious bookmarks and Twitter stuff
class Social
  class << self
    # Gets the repositories for a Github user, that aren't forks, with a certain probability
    #
    # @param [String] username The Github username
    # @param [Float] prob The probability of including any given repository
    # @return [Array] An array of Hashie::Mash object of all the repositories the user has that made the cut
    def repositories(username, prob = 0.6)
      resp = RestClient.get("http://github.com/api/v1/json/#{username}")
      resp = Hashie::Mash.new(Crack::JSON.parse(resp))
      resp.user.repositories.reject do |r|
        r.fork
      end.select do |r|
        rand < prob
      end.sort do |l,r|
        l.name <=> r.name
      end
    end

    # Gets shared Google Reader items for an id
    #
    # @see http://github.com/pauldix/feedzirra feedzirra gem
    # @param [Integer] id The id of the Google Reader feed
    # @param [Integer] num The max number of items to include
    # @return [Array] An array of Feedzirra items
    def shared_items(id, num = 8)
      url = "http://www.google.com/reader/public/atom/user/#{id}/state/com.google/broadcast"
      Feedzirra::Feed.fetch_and_parse(url).entries[0,num]
    end

    # Gets the most recent tweets for a Twitter user
    #
    # @see http://github.com/jnunemaker/twitter twitter gem
    # @param [String] username The Twitter username
    # @param [Integer] num The max number of tweets to return
    # @return [Array] An array of Hashie::Mash objects of all the tweets
    def tweets(username, num = 4)
      Twitter::Search.new.from(username).to_a[0,num]
    end

    # Gets a single tweet using authentication for rate limit purposes
    #
    # @param [Integer] id The id of the tweet
    # @param [String] username The Twitter username to authenticate as
    # @param [String] password The password to authenticate with
    # @return [Hashie::Mash] The tweet
    def tweet(id, username, password)
      Hashie::Mash.new(Crack::JSON.parse(RestClient.get("https://twitter.com/statuses/show/#{id}.json", 'User-Agent' => Blog.user_agent, :user => username, :password => password)))
    end

    # Gets latest bookmarks from Delicious for a user
    #
    # @param [String] username The Delicious username to use
    # @param [String] password The password to use
    # @param [Integer] num The max number of bookmarks to return
    # @return [Array] An array of the bookmarks
    def bookmarks(username, password, num = 8)
      Hashie::Mash.new(Crack::XML.parse(RestClient.get("https://#{username}:#{password}@api.del.icio.us/v1/posts/recent?count=#{num}", 'User-Agent' => Blog.user_agent))).posts.post
    end
  end
end