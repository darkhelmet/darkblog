require 'hashie'

# Helper class to get certain social web things, like Delicious bookmarks and Twitter stuff
class Social
  class << self
    # Gets the repositories for a Github user, that aren't forks, with a certain probability
    #
    # @param [String] username The Github username
    # @param [Float] prob The probability of including any given repository
    # @return [Array] An array of Hashie::Mash object of all the repositories the user has that made the cut
    def repositories(username, num = 12)
      resp = Hashie::Mash.new(Crack::JSON.parse(RestClient.get("http://github.com/api/v1/json/#{username}")))
      resp.user.repositories.reject { |r| r.fork }.sort_by { rand }[0,num]
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

    def where
      @@where ||= Hashie::Mash.new(YAML.load_file(File.join('config', 'where.yml')))
    end
  end
end