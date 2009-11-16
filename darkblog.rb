#!/usr/bin/env ruby

$KCODE = 'u'

$: << File.expand_path(File.join('.', 'lib'))

require 'rubygems'
require 'sinatra'
require 'haml'
require 'builder'
require 'activerecord'
require 'activesupport'
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

STATIC_PATHS = %w(image javascripts stylesheets favicon.ico sitemap.xsl swf).map { |p| "^/#{p}" }

if development?
  require 'ruby-debug'
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

WillPaginate::ViewHelpers::LinkRenderer.class_eval do
protected

  def url(page)
    path = @template.request.path
    case path
    when /tag|category/
      1 == page ? "/#{path.split('/')[1,2].join('/')}" : "/#{path.split('/')[1,2].join('/')}/page/#{page}"
    when /\/(\d{4})\/(\d{2})/
      1 == page ? "/#{$1}/#{$2}" : "/#{$1}/#{$2}/page/#{page}"
    else
      1 == page ? '/' : "/page/#{page}"
    end
  end
end

configure do
  Blog = OpenStruct.new(:title => ENV['BLOG_TITLE'] || 'verbose logging',
                        :tagline => ENV['BLOG_TAGLINE'] || 'programming, software development, and code',
                        :index => ENV['BLOG_INDEX'] || 'http://blog.darkhax.com/',
                        :host => ENV['BLOG_HOST'] || 'blog.darkhax.com',
                        :email => ENV['BLOG_EMAIL'] || 'darkhelmet@darkhelmetlive.com',
                        :username => ENV['BLOG_USERNAME'] || 'darkhelmet',
                        :author => ENV['BLOG_AUTHOR'] || 'Daniel Huckstep',
                        :bio => ENV['BLOG_BIO'] || 'is a software engineer (EIT) in Edmonton, Alberta, Canada',
                        :feedburner => ENV['BLOG_FEEDBURNER'] || 'VerboseLogging',
                        :password => ENV['BLOG_PASSWORD'] || 'password',
                        :github => ENV['BLOG_GITHUB'] || 'darkhelmet',
                        :twitter => ENV['BLOG_TWITTER'] || 'darkhelmetlive',
                        :twitter_password => ENV['BLOG_TWITTER_PASSWORD'] || '',
                        :delicious_user => ENV['BLOG_DELICIOUS_USER'] || 'darkhelmetlive',
                        :delicious_password => ENV['BLOG_DELICIOUS_PASSWORD'] || 'secret',
                        :reader_id => ENV['BLOG_READER_ID'] || '13098793136980097600',
                        :messagepub_key => ENV['BLOG_MESSAGEPUB_KEY'] || '',
                        :disqus => ENV['BLOG_DISQUS'] || 'verboselogging',
                        :per_page => ENV['BLOG_PER_PAGE'] || 10,
                        :tz => TZInfo::Timezone.get('America/Edmonton'),
                        :tz_display => 'MDT',
                        :fogbugz_host => ENV['BLOG_FOGBUGZ_HOST'] || 'darkhax.fogbugz.com',
                        :fogbugz_user => ENV['BLOG_FOGBUZ_USER'] || 'Daniel Huckstep',
                        :fogbugz_project => ENV['BLOG_FOGBUZ_PROJECT'] || 'darkhax',
                        :fogbugz_area => ENV['BLOG_FOGBUZ_AREA'] || 'Blog')
end

configure :production do
  not_found do
    not_found_notification
    haml(:not_found)
  end
end

before do
  unless STATIC_PATHS.any? { |path| env['PATH_INFO'].match(path) }
    if production?
      expires_in(10.minutes) if env['REQUEST_METHOD'] =~ /GET|HEAD/
    end
    setup_top_panel
  end
end

require 'models'

helpers do
  include Sinatra::Authorization
  include TagsHelper
  include WillPaginate::ViewHelpers::Base

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

  def setup_top_panel
    @repos = Cache.get('github', 1.day) do
      resp = RestClient.get("http://github.com/api/v1/json/#{Blog.github}")
      Crack::JSON.parse(resp)['user']['repositories'].reject do |r|
        r['fork']
      end.select do |r|
        rand < 0.75
      end.sort do |l,r|
        l['name'] <=> r['name']
      end
    end

    @tweets = Cache.get('twitter', 10.minutes) do
      Twitter::Search.new.from(Blog.twitter).to_a[0,6]
    end

    @bookmarks = Cache.get('delicious', 6.hours) do
      WWW::Delicious.new(Blog.delicious_user, Blog.delicious_password).posts_recent[0,6]
    end

    @shared_items = Cache.get('reader', 6.hours) do
      url = "http://www.google.com/reader/public/atom/user/#{Blog.reader_id}/state/com.google/broadcast"
      Feedzirra::Feed.fetch_and_parse(url).entries[0,6]
    end
  end

  def tweet(t)
    t.text.gsub(/(https?:\/\/\S+)/, '<a href="\1">\1</a>').gsub(/@(\w+)/i, '<a href="http://twitter.com/\1">@\1</a>').gsub(/#(\w+)/, '<a href="http://twitter.com/#search?q=%23\1">#\1</a>')
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

  def expires_in(time)
    headers['Cache-Control'] = "public, max-age=#{time}"
  end

  def no_cache
    headers['Cache-Control'] = 'no-cache'
  end

  def announce
    Post.published.unannounced.each(&:announce)
  end

  def h(s)
    s.nil? ? '' : CGI.escapeHTML(s)
  end
end

use Rack::CanonicalHost, Blog.host if production?
use Rack::StaticCache, :urls => STATIC_PATHS, :root => 'public', :compress => true if production?
use Rack::RemoveSlash
use Rack::ResponseTimeInjector, :format => '%.3f'
use Rack::GoogleAnalytics, 'UA-2062105-4' if production?
use Rack::InlineCompress, :ignore => ['/feed'] if production?
use Rack::ETag
use Rack::BugzScout, "https://#{Blog.fogbugz_host}/scoutsubmit.asp", Blog.fogbugz_user, Blog.fogbugz_project, Blog.fogbugz_area if production?

named_routes[:index] = %r|^/(?:page/(\d+))?$|
named_routes[:monthly] = %r|^/(\d{4})/(\d{2})(?:/page/(\d+))?$|
named_routes[:category] = %r|^/category/(\w+)(?:/page/(\d+))?$|
named_routes[:feed] = %r|^/feed.*|
named_routes[:sitemap] = %r|^/sitemap.xml(.gz)?$|
named_routes[:google] = '/google-search'
named_routes[:permalink] = %r|^(/\d{4}/\d{2}/\d{2}/[\w\d\-+ ]+)$|
named_routes[:tag] = %r|^/tag/([\w\-.]+)(?:/page/(\d+))?$|
named_routes[:edit_post] = %r|^(/\d{4}/\d{2}/\d{2}/[\w\d\-+ ]+)/edit$|
named_routes[:preview_post] = %r|^(/\d{4}/\d{2}/\d{2}/[\w\d\-+ ]+)/preview$|
named_routes[:posts] = '/posts'
named_routes[:redirections] = '/redirections'
named_routes[:announce] = '/announce'
named_routes[:admin_index] = '/index'

# main index with pagination
# get %r|^/(?:page/(\d+))?$| do |page|
named_route(:get, :index) do |page|
  page ||= '1'
  page = page.to_i
  @posts = Post.published.paginate(:page => page, :per_page => Blog.per_page)
  not_found('Not Found') if @posts.empty?
  @future_post = Post.future.last if 1 == page
  title("Page #{page}") if 1 < page
  haml(:posts)
end

# monthly archive with pagination
named_route(:get, :monthly) do |year,month,page|
  page ||= '1'
  page = page.to_i
  date = DateTime.strptime("#{year}-#{month}-1 #{Blog.tz_display}", '%F %Z')
  @posts = Post.published.monthly(date).paginate(:page => page, :per_page => Blog.per_page)
  not_found if @posts.empty?
  title(date.strftime('%B %Y'), page)
  haml(:posts)
end

# category index with pagination
named_route(:get, :category) do |category,page|
  page ||= '1'
  page = page.to_i
  @posts = Post.published.category(category).paginate(:page => page, :per_page => Blog.per_page)
  not_found if @posts.empty?
  title(category.capitalize, page)
  haml(:posts)
end

# rss feed
named_route(:get, :feed) do
  if env['HTTP_USER_AGENT'].match(/feedburner/i) || development?
    @posts = Post.published.all(:limit => 10)
    content_type('application/rss+xml', :charset => 'utf-8')
    builder(:feed)
  else
    redirect(fb_url, 301)
  end
end

# sitemap
named_route(:get, :sitemap) do |gzip|
  @posts = Post.published
  content_type('application/xml', :charset => 'utf-8')
  builder(:sitemap)
end

# google search
named_route(:get, :google) do
  haml(:page, :locals => { :page => :google })
end

# information pages
%w(about contact disclaimer).each do |page|
  named_routes[page.intern] = "/#{page}"
  named_route(:get, page.intern) do
    title(page.capitalize)
    haml(:page, :locals => { :page => page.intern })
  end
end

# permalinks
named_route(:get, :permalink) do |permalink|
  @posts = Post.published.perma(permalink).paginate(:page => 1, :per_page => 1)
  if @posts.empty?
    r = Redirection.first(:conditions => { :old_permalink => permalink })
    if r.nil?
      not_found
    else
      redirect(r.post.permalink, 301)
      return
    end
  end
  title(@posts.first.title)
  disqus_part('disqus_single')
  request.xhr? ? haml(:posts, :layout => false) : haml(:posts)
end

# tags with pagination
named_route(:get, :tag) do |tag,page|
  page ||= '1'
  page = page.to_i
  @posts = Post.published.find_tagged_with(tag, :match_all => true).paginate(:page => page, :per_page => Blog.per_page)
  not_found if @posts.empty?
  title(tag, page)
  haml(:posts)
end

# edit post
named_route(:get, :edit_post) do |permalink|
  no_cache
  require_administrative_privileges
  @post = Post.perma(permalink).first
  title("Editing '#{@post.title}'")
  haml(:edit_post, :layout => :admin)
end

# preview post
named_route(:get, :preview_post) do |permalink|
  no_cache
  require_administrative_privileges
  @posts = Post.perma(permalink).paginate(:page => 1, :per_page => Blog.per_page)
  title(@posts.first.title)
  disqus_part('disqus_single')
  haml(:posts)
end

# new post
named_route(:get, :posts) do
  no_cache
  require_administrative_privileges
  @post = Post.new
  title('New Post')
  haml(:edit_post, :layout => :admin)
end

# create new post
named_route(:post, :posts) do
  no_cache
  require_administrative_privileges
  published = params['post']['published']
  params['post']['published'] = (published.nil? || 'false' == published) ? false : true
  if post = Post.create(params['post'])
    redirect("#{post.permalink}/edit")
  else
    redirect('/posts')
  end
end

# update existing post
named_route(:put, :posts) do
  no_cache
  require_administrative_privileges
  published = params['post']['published']
  params['post']['published'] = (published.nil? || 'false' == published) ? false : true
  post = Post.find(params['post'].delete('id'))
  if post.published && params['post'].has_key?('title') && post.title.parameterize != params['post']['title'].parameterize
    Redirection.create(:post => post, :old_permalink => post.permalink)
  end
  post.update_attributes(params['post'])
  redirect("#{post.permalink}/edit")
end

# redirection form
named_route(:get, :redirections) do
  no_cache
  require_administrative_privileges
  haml(:edit_redirection, :layout => :admin)
end

# create redirection
named_route(:post, :redirections) do
  no_cache
  require_administrative_privileges
  r = Redirection.create(params['redirection'])
  content_type('application/xml')
  r.to_xml
end

# force update twitter
named_route(:post, :announce) do
  no_cache
  require_administrative_privileges
  announce
  ''
end

# admin index
named_route(:get, :admin_index) do
  no_cache
  require_administrative_privileges
  @posts = Post.unpublished.all
  haml(:admin_index, :layout => :admin)
end