require 'haml'
require 'builder'
require 'active_record'
require 'active_support'
require 'will_paginate'
require 'will_paginate/finders/active_record'
require 'will_paginate/view_helpers/base'
require 'will_paginate/view_helpers/link_renderer'
require 'acts_as_taggable_on_steroids'
require 'tag'
require 'tag_list'
require 'tagging'
require 'tags_helper'
require 'ostruct'
require 'RedCloth'
require 'crack'
require 'restclient'
require 'tzinfo'
require 'rainpress'
require 'packr'
require 'hpricot'
require 'bugzscout'
# require 'newrelic_rpm'
require 'sanitize'
require 'social'

%w(authorization named_routes).each do |ext|
  require "sinatra/#{ext}"
end

%w(etag static_cache remove_slash inline_compress canonical_host google_analytics response_time_injector bugzscout).each do |ext|
  require "rack/#{ext}"
end

class String
  # Encodes the string for use in a URL
  #
  # @return [String] The string escaped for URL usage
  def url_encode
    CGI.escape(self)
  end
end

# Helpers for the blog
module BlogHelper
  # View related helpers
  module ViewHelpers
    # HTML escapes things
    #
    # @param [String] s The string to escape
    # @return [String] The freshly escaped string
    def h(s)
      CGI.escapeHTML(s.to_s)
    end

    # Turns a tweet from the Twitter gem into HTML to be inserted into the page
    #
    # @see http://github.com/jnunemaker/twitter Twitter gem
    # @param [Hashie::Mash] t A tweet from the Twitter gem
    # @return [String] HTML of the tweet, with links made, and a permalink with date and time
    def tweet(t)
      txt = t.text
      txt.gsub!(/(https?:\/\/\S+)/, '<a href="\1">\1</a>')
      txt.gsub!(/@(\w+)/i, '<a href="http://twitter.com/\1">@\1</a>')
      txt.gsub!(/#(\w+)/, '<a href="http://twitter.com/#search?q=%23\1">#\1</a>')
      d = Blog.tz.utc_to_local(DateTime.parse(t.created_at))
      txt + "<br /><a class='tweet-date' href='http://twitter.com/#{t.from_user}/status/#{t.id}'>#{d.strftime("%d-%m-%Y %I:%M %p #{Blog.tz_display}")}</a>"
    end

    # Get the link to the author's Twitter profile
    #
    # @return [String] HTML link to the Twitter profile with the text 'Follow me on twitter'
    def twitter_link
      partial("%a{ :href => 'http://twitter.com/#{Blog.twitter}' } Follow me on twitter")
    end

    # Turns a Delicious bookmark into a link for insertion into the page
    #
    # @see http://github.com/weppos/www-delicious www-delicious gem
    # @param [WWW::Delicious::Post] b A bookmark/post from the www-delicious gem
    # @return [String] HTML link to the bookmark
    def delicious(b)
      partial("%a{ :href => '#{b.url.to_s}' } #{h(b.title)}")
    end

    # Get the link to the author's Delicious profile and to add to your network
    #
    # @return [String] The HTML insertion-ready string with the relevant links
    def delicious_link
      partial("I'm\n%a{ :href => 'http://delicious.com/#{Blog.delicious_user}' } #{Blog.delicious_user}\non Delicious.\n<br />\n%a{ :href => 'http://delicious.com/network?add=#{Blog.delicious_user}'} Add me to your network")
    end

    # Turns a shared RSS item into a link for insertion into the page
    #
    # @see http://github.com/pauldix/feedzirra feedzirra gem
    # @param [Object] item An RSS item from the Feedzirra gem
    # @return [String] HTML link to the shared item
    def reader(item)
      partial("%a{ :href => '#{item.url}' } #{h(item.title)}")
    end

    # Turns a Github repo from the Github API into a link to it
    #
    # @param [Hashie::Mash] r A repository
    # @return [String] HTML link to the Github repo
    def repo(r)
      partial("%a{ :href => '#{r['url']}' } #{h(r['name'])}")
    end

    # Get the author's Github profile link
    #
    # @return [String] The HTML insertion-ready string with the link to the Github profile
    def github_link
      partial("%a{ :href => 'https://github.com/#{Blog.github}' } Fork me on Github, and see the rest of my code")
    end

    # Setup or get the disqus part to include after a post
    #
    # @overload disqus_part(nil)
    #   Retrieve the Disqus partial to use
    #   @return [Symbol] :disqus_index unless it has been previously set
    # @overload disqus_part(part)
    #   Set the disqus_part to use
    #   @param [String] part The part to use, 'disqus_single' or 'disqus_index'
    def disqus_part(part = nil)
      if part.nil?
        (@disqus_part || 'disqus_index').intern
      else
        @disqus_part = part
      end
    end

    # Setup or get the post to use for keywords
    #
    # @overload keywords_post(nil)
    #   Get the post to use for keywords
    #   @return [Post] The post to use for keywords
    # @overload keywords_post(post)
    #   Set the keywords post
    #   @param [Post] post The post to use for keywords
    def keywords_post(post = nil)
      if post.nil?
        @keywords_post
      else
        @keywords_post = post
      end
    end

    # Get the FeedBurner URL for the blog
    #
    # @return [String] The URL to the FeedBurner feed
    def fb_url
      "http://feeds.feedburner.com/#{Blog.feedburner}"
    end

    # Get a Gravatar URL for an email
    #
    # @param [String] email The email to use
    # @return [String] The url to the Gravatar png image
    def gravatar_url(email)
      "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}.png"
    end

    # Generate a HAML partial for a link to a tag
    #
    # @param [Tag,String] tag The tag to create a link to
    # @param [String] css The CSS class (.foo) or id (#bar) to use
    # @return [String] A partial that can be fed to HAML using {#partial}
    def tag_partial(tag, css = '')
      tag = tag.to_s
      "%a#{css}{ :href => '/tag/#{tag.url_encode}', :rel => 'tag' } #{h(tag)}"
    end

    # Bundles up {#tag_partial} and {#partial} into one call
    #
    # @param [Tag,String] tag The tag to create a link to
    # @param [String] css The CSS class (.foo) or id (#bar) to use
    # @return [String] HTML that can be inserted into the page
    def tag_link(tag, css = '')
      partial(tag_partial(tag, css))
    end

    # Creates the HTML links for all the tags in a post
    #
    # @param [Post] post The post to use
    # @return [String] HTML ready to be inserted into the page
    def tag_links(post)
      partial(post.tag_list.map { |tag| tag_partial(tag) }.join("\n"))
    end

    # Creates the CSS class for a post
    #
    # @param [Post] post The post to use
    # @return [String] The CSS class to be used
    def post_class(post)
      (post.tag_list.map { |tag| "tag-#{h(tag)}" } | ['post', "post-#{post.id}", "category-#{h(post.category)}"]).join(' ')
    end

    # Get the absolute permalink to a post
    #
    # @param [Post] post The post to create the link to
    # @return [String] The full URL including protocol and host
    def post_permaurl(post)
      Blog.index + post.permalink[1..-1]
    end

    def category_link(cat)
      partial("%a{ :href => '/category/#{cat.url_encode}' } #{h(cat).capitalize}")
    end

    def next_month(year, month)
      if 12 == month
        year += 1
        month = 1
        return year, month
      else
        return year, month + 1
      end
    end

    def monthly_archive_links
      newest = Post.published.first
      return Array.new if newest.nil?
      oldest = Post.published.last
      year = oldest.published_on_local.year
      month = oldest.published_on_local.month

      links = Array.new
      while year <= newest.published_on_local.year && month <= newest.published_on_local.month
        date = Date.new(year,month,1)
        links << partial("%a{ :href => '/#{date.strftime('%Y/%m')}' } #{date.strftime('%B %Y')}")
        year, month = next_month(year,month)
      end
      links
    end

    # TODO: Refactor to support :collection
    def partial(page, options = {})
      if options.delete(:cache)
        Cache.get("#{page.to_s}_partial", options.delete(:cache_max_age) || 10.minutes) do
          haml(page, options.merge(:layout => false))
        end
      else
        haml(page, options.merge(:layout => false))
      end
    end

    def stylesheet_link_tag(sheet, media = 'screen,projection')
      link = sheet.include?('http://') ? sheet : "/stylesheets/#{sheet}.css"
      partial("%link{ :type => 'text/css', :href => '#{link}', :rel => 'stylesheet', :media => '#{media}' }")
    end

    def javascript_include_tag(js)
      link = js.include?('http://') ? js : "/javascripts/#{js}.js"
      partial("%script{ :type => 'text/javascript', :src => '#{link}' }")
    end

    def image_tag(img, alt = img.split('/').last)
      link = img.include?('http://') ? img : "/images/#{img}"
      partial("%img{ :src => '#{link}', :alt => '#{alt}' }")
    end

    def title(t = nil, page = 1)
      if t.nil?
        @title || Blog.title
      else
        @title = "#{t} | #{Blog.title}"
        if 1 < page
          @title += " | Page #{page}"
        end
      end
    end
  end

  module Utilities
    def sharing(on = nil)
      @sharing ||= on
    end

    def user_agent
      env['HTTP_USER_AGENT']
    end

    def user_agent?(s)
      user_agent.try(:match, s)
    end

    def setup_top_panel
      unless user_agent?(/google/i)
        @repos = Cache.get('github', 1.day) { Social.repositories(Blog.github) }
        @tweets = Cache.get('twitter', 10.minutes) { Social.tweets(Blog.twitter) }
        @bookmarks = Cache.get('delicious', 6.hours) { Social.bookmarks(Blog.delicious_user, Blog.delicious_password) }
        @shared_items = Cache.get('reader', 6.hours) { Social.shared_items(Blog.reader_id) }
      end
    end

    def remote_hostname
      host = env['REMOTE_ADDR'].split(',').first.strip
      Socket.getaddrinfo(host, nil)[0][2]
    end

    def not_found_notification
      if named_routes.values.any? { |path| path.match(env['REQUEST_PATH']) }
        FogBugz::BugzScout.submit("https://#{Blog.fogbugz_host}/scoutsubmit.asp") do |scout|
          scout.user = Blog.fogbugz_user
          scout.project = Blog.fogbugz_project
          scout.area = Blog.fogbugz_area
          scout.title = "404 Not Found - #{env['PATH_INFO']}"
          scout.body = "Remote host: #{remote_hostname} (#{env['REMOTE_ADDR']})"
        end
      end
    rescue Exception => e
    end

    def announce
      RestClient.get('http://pingomatic.com/ping/?title=verbose+logging&blogurl=http%3A%2F%2Fblog.darkhax.com%2F&rssurl=http%3A%2F%2Fblog.darkhax.com%2Ffeed&chk_weblogscom=on&chk_blogs=on&chk_technorati=on&chk_feedburner=on&chk_syndic8=on&chk_newsgator=on&chk_myyahoo=on&chk_pubsubcom=on&chk_blogdigger=on&chk_blogrolling=on&chk_blogstreet=on&chk_moreover=on&chk_weblogalot=on&chk_icerocket=on&chk_newsisfree=on&chk_topicexchange=on&chk_google=on&chk_tailrank=on&chk_bloglines=on&chk_postrank=on&chk_skygrid=on&chk_collecta=on')
      RestClient.get('http://feedburner.google.com/fb/a/pingSubmit?bloglink=http://blog.darkhax.com/')
    end

    def individual_tweet(id)
      Cache.get("twitter:status:#{id}", 1.year) { Social.tweet(id, Blog.twitter, Blog.twitter_password) }
    end
  end

  module Caching
    def expires_in(time)
      headers['Cache-Control'] = "public, max-age=#{time}"
    end

    def no_cache
      headers['Cache-Control'] = 'no-cache'
    end
  end
end

STATIC_PATHS = %w(image javascripts stylesheets favicon.ico sitemap.xsl swf).map { |p| "^/#{p}" }

if development?
  require 'ruby-debug'
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

WillPaginate::ViewHelpers::LinkRenderer.class_eval do
protected

  def url(page)
    path = @template.request.path
    params = @template.request.params
    case path
    when /tag|category/
      1 == page ? "/#{path.split('/')[1,2].join('/')}" : "/#{path.split('/')[1,2].join('/')}/page/#{page}"
    when /\/(\d{4})\/(\d{2})/
      1 == page ? "/#{$1}/#{$2}" : "/#{$1}/#{$2}/page/#{page}"
    when /\/search/
      1 == page ? "/search?q=#{params['q']}" : "/search/page/#{page}?q=#{params['q']}"
    else
      1 == page ? '/' : "/page/#{page}"
    end
  end
end

class String
  def matches_any_of?(*args)
    args.any? { |a| self.match(a) }
  end
end