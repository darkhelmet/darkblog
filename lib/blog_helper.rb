require 'haml'
require 'builder'
require 'active_record'
require 'active_support'

%w(markup render routing).each do |plugin|
  require "sinatra/#{plugin}_plugin"
end

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
require 'archive_date'

require 'sinatra/authorization'

%w(etag static_cache remove_slash inline_compress canonical_host google_analytics response_time_injector bugzscout tweetboard).each do |ext|
  require "rack/#{ext}"
end

class String
  # Encodes the string for use in a URL
  #
  # @return [String] The string escaped for URL usage
  def url_encode
    Rack::Utils.escape(self)
  end
end

# Helpers for the blog
module BlogHelper
  # View related helpers
  module ViewHelpers
    def sidebar
      if production?
        Cache.get('right_sidebar_partial', 1.hour) { partial(:right_sidebar) }
      else
        partial(:right_sidebar)
      end
    end

    # Turns a Delicious bookmark into a link for insertion into the page
    #
    # @see http://github.com/weppos/www-delicious www-delicious gem
    # @param [WWW::Delicious::Post] b A bookmark/post from the www-delicious gem
    # @return [String] HTML link to the bookmark
    def delicious(b)
      link_to(h(b.description), b.href)
    end

    # Get the link to the author's Delicious profile and to add to your network
    #
    # @return [String] The HTML insertion-ready string with the relevant links
    def delicious_link
      profile_link = link_to(Blog.delicious_user, "http://delicious.com/#{Blog.delicious_user}")
      add_link = link_to('Add me to your network', "http://delicious.com/network?add=#{Blog.delicious_user}")
      "I'm #{profile_link} on Delicious.<br />#{add_link}"
    end

    # Turns a shared RSS item into a link for insertion into the page
    #
    # @see http://github.com/pauldix/feedzirra feedzirra gem
    # @param [Object] item An RSS item from the Feedzirra gem
    # @return [String] HTML link to the shared item
    def reader(item)
      link_to(h(item.title), item.url)
    end

    # Turns a Github repo from the Github API into a link to it
    #
    # @param [Hashie::Mash] r A repository
    # @return [String] HTML link to the Github repo
    def repo(r)
      link_to(h(r.name), r.url, :title => h(r.description), :class => 'github')
    end

    # Get the author's Github profile link
    #
    # @return [String] The HTML insertion-ready string with the link to the Github profile
    def github_link
      link_to('Fork me on Github, and see the rest of my code', "https://github.com/#{Blog.github}")
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
      "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}.jpg?s=120"
    end

    # Generate a link to a tag
    #
    # @param [Tag,String] tag The tag to create a link to
    # @param [String] css The CSS class (foo)
    # @return [String] A partial that can be fed to HAML using {#partial}
    def tag_link(tag, css = '')
      tag = tag.to_s
      link_to(h(tag), "/tag/#{tag.url_encode}", :rel => 'tag', :class => css)
    end

    # Creates the HTML links for all the tags in a post
    #
    # @param [Post] post The post to use
    # @return [String] HTML ready to be inserted into the page
    def tag_links(post)
      post.tag_list.map { |tag| tag_link(tag) }.join("\n")
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
      link_to(h(cat.capitalize), "/category/#{cat.url_encode}")
    end

    def archive_link(date)
      link_to(date.strftime('%B %Y'), "/#{date.strftime('%Y/%m')}")
    end

    def monthly_archive_links
      newest = Post.published.first
      return Array.new if newest.nil?
      newest = newest.published_on_local
      oldest = Post.published.last.published_on_local

      (ArchiveDate.new(oldest.year, oldest.month, 1)..ArchiveDate.new(newest.year, newest.month, 1)).map do |date|
        archive_link(date)
      end
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
        @bookmarks = Cache.get('delicious', 1.day) { Social.bookmarks(Blog.delicious_user, Blog.delicious_password) }
        @shared_items = Cache.get('reader', 1.day) { Social.shared_items(Blog.reader_id) }
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

  module Test
    def good_get(*args)
      get(*args)
      last_response.should be_ok
    end

    def bad_get(*args)
      get(*args)
      last_response.should_not be_ok
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