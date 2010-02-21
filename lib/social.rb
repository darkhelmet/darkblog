require 'hashie'

# Helper class to get certain social web things, like Delicious bookmarks and Twitter stuff
class Social
  class << self
    # Gets a single tweet using authentication for rate limit purposes
    #
    # @param [Integer] id The id of the tweet
    # @param [String] username The Twitter username to authenticate as
    # @param [String] password The password to authenticate with
    # @return [Hashie::Mash] The tweet
    def tweet(id, username, password)
      Hashie::Mash.new(Crack::JSON.parse(RestClient.get("https://twitter.com/statuses/show/#{id}.json", 'User-Agent' => Blog.user_agent, :user => username, :password => password)))
    end

    def where
      @@where ||= Hashie::Mash.new(YAML.load_file(File.join('config', 'where.yml')))
    end
  end
end