require 'haml'
require 'builder'
require 'active_record'
require 'active_support'
require 'will_paginate'
require 'will_paginate/finders/active_record'
require 'will_paginate/view_helpers/base'
require 'will_paginate/view_helpers/link_renderer'
require 'acts_as_taggable'
require 'tag'
require 'tag_list'
require 'tagging'
require 'tags_helper'
require 'ostruct'
require 'RedCloth'
require 'crack'
require 'restclient'
require 'www/delicious'
require 'feedzirra'
require 'twitter'
require 'sinatra/authorization'
require 'sinatra/named_routes'
require 'rack/etag'
require 'rack/static_cache'
require 'rack/remove_slash'
require 'tzinfo'
require 'rack/canonical_host'
require 'rack/google_analytics'
require 'rack/response_time_injector'
require 'rainpress'
require 'packr'
require 'hpricot'
require 'rack/inline_compress'
require 'bugzscout'
require 'rack/bugzscout'
# require 'newrelic_rpm'
require 'texticle'
require 'term_extraction'
require 'sanitize'

module BlogHelper
  module ViewHelpers
    def h(s)
      s.nil? ? '' : CGI.escapeHTML(s)
    end

    def tweet(t)
      txt = t.text
      txt.gsub!(/(https?:\/\/\S+)/, '<a href="\1">\1</a>')
      txt.gsub!(/@(\w+)/i, '<a href="http://twitter.com/\1">@\1</a>')
      txt.gsub!(/#(\w+)/, '<a href="http://twitter.com/#search?q=%23\1">#\1</a>')
      d = Blog.tz.utc_to_local(DateTime.parse(t.created_at))
      txt + "<br /><a class='tweet-date' href='http://twitter.com/#{t.from_user}/status/#{t.id}'>#{d.strftime("%d-%m-%Y %I:%M %p #{Blog.tz_display}")}</a>"
    end

    def twitter_link
      partial("%a{ :href => 'http://twitter.com/#{Blog.twitter}'} Follow me on twitter")
    end

    def delicious(b)
      partial("%a{ :href => '#{b.url.to_s}' } #{b.title}")
    end

    def delicious_link
      partial("I'm\n%a{ :href => 'http://delicious.com/#{Blog.delicious_user}' } #{Blog.delicious_user}\non Delicious.\n<br />\n%a{ :href => 'http://delicious.com/network?add=#{Blog.delicious_user}'} Add me to your network")
    end

    def reader(s)
      partial("%a{ :href => '#{s.url}' } #{s.title}")
    end

    def repo(r)
      partial("%a{ :href => '#{r['url']}' } #{r['name']}")
    end

    def github_link
      partial("%a{ :href => 'https://github.com/#{Blog.github}' } Fork me on Github")
    end

    def disqus_part(part = nil)
      if part.nil?
        @disqus_part || 'disqus_index'
      else
        @disqus_part = part
      end
    end

    def keywords_post(post = nil)
      if post.nil?
        @keywords_post
      else
        @keywords_post = post
      end
    end

    def fb_url
      "http://feeds.feedburner.com/#{Blog.feedburner}"
    end

    def gravatar_url(email)
      "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}"
    end

    def tag_link(tag)
      partial("%a{ :href => '/tag/#{tag}', :rel => 'tag' } #{tag}")
    end

    def tag_links(post)
      post.tag_list.map { |tag| tag_link(tag) }.join(' ')
    end

    def post_class(post)
      (post.tag_list.map { |tag| "tag-#{tag}" } | ['post', "post-#{post.id}", "category-#{post.category}"]).join(' ')
    end

    def post_permaurl(post)
      Blog.index + post.permalink[1..-1]
    end

    def category_link(cat)
      partial("%a{ :href => '/category/#{cat}' } #{cat.capitalize}")
    end

    def next_month(year,month)
      if 12 == month
        year += 1
        month = 1
        return year,month
      else
        return year,month + 1
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
        @title = "#{Blog.title} | #{t}"
        if 1 < page
          @title += " Page #{page}"
        end
      end
    end

    def keywords(k = nil)
      @keywords ||= k
    end
  end

  module Utilities
    def user_agent
      env['HTTP_USER_AGENT']
    end

    def user_agent?(s)
      user_agent.try(:match, s)
    end

    def setup_top_panel
      return if user_agent?(/google/i)
      @repos = Cache.get('github', 1.day) do
        resp = RestClient.get("http://github.com/api/v1/json/#{Blog.github}")
        Crack::JSON.parse(resp)['user']['repositories'].reject do |r|
          r['fork']
        end.select do |r|
          rand < 0.60
        end.sort do |l,r|
          l['name'] <=> r['name']
        end
      end

      @tweets = Cache.get('twitter', 10.minutes) do
        Twitter::Search.new.from(Blog.twitter).to_a[0,6]
      end

      @bookmarks = Cache.get('delicious', 6.hours) do
        WWW::Delicious.new(Blog.delicious_user, Blog.delicious_password).posts_recent[0,8]
      end

      @shared_items = Cache.get('reader', 6.hours) do
        url = "http://www.google.com/reader/public/atom/user/#{Blog.reader_id}/state/com.google/broadcast"
        Feedzirra::Feed.fetch_and_parse(url).entries[0,8]
      end
    end

    def remote_hostname
      host = env['REMOTE_ADDR'].split(',').first.strip
      Socket.getaddrinfo(host, nil)[0][2]
    end

    def not_found_notification
      if named_routes.values.any? { |path| path.match(env['REQUEST_PATH']) }
        FogBugz::BugzScout.submit("https://#{Blog.fogbugz_host}:/scoutsubmit.asp") do |scout|
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

ActiveRecord::Base.extend(Texticle)

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