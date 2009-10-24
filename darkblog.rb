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
require 'messagepub'
require 'tzinfo'
require 'run_later'

if development?
  require 'ruby-debug'
  ActiveRecord::Base.logger = Logger.new('db.log')
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
                        :notify_email => ENV['BLOG_NOTIFY_EMAIL'] || '',
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
                        :tz_display => 'MDT')
end

configure :production do
  not_found do
    not_found_notification
    haml(:not_found)
  end
  
  error { error_notification }
end

before do
  if production?
    if env['HTTP_HOST'] != Blog.host
      redirect("http://#{Blog.host}#{env['REQUEST_PATH']}", 301)
    end
    
    expires_in(10.minutes) if env['REQUEST_METHOD'] =~ /GET|HEAD/
  end
  
  begin
    params.symbolize_keys!
    params.each do |k,v|
      v.symbolize_keys! if v.is_a?(Hash)
    end
  rescue
  end
  
  setup_top_panel
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
    t.text.gsub(/(https?:\/\/\S+)/, '<a href="\1">\1</a>').gsub(/@(\w+)/i, '<a href="http://twitter.com/\1">@\1</a>')
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
  
  def notify(subject, body)
    return if Blog.messagepub_key.nil?
    c = MessagePub::Client.new(Blog.messagepub_key)
    n = MessagePub::Notification.new(:subject => subject, :body => body)
    n.add_recipient(MessagePub::Recipient.new(:position => 1, :channel => 'email', :address => Blog.notify_email))
    c.create!(n)
  rescue Exception => e
  end
  
  def remote_hostname
    host = env['REMOTE_ADDR'].split(',').first.strip
    Socket.getaddrinfo(host, nil)[0][2]
  end
  
  def not_found_notification
    if named_routes.values.any? { |path| path.match(env['REQUEST_PATH']) }
      notify("[#{Blog.title}] 404 Not Found", "Client at #{remote_hostname} (#{env['REMOTE_ADDR']}) tried to get #{env['PATH_INFO']}")
    end
  rescue Exception => e
  end
  
  def error_notification
    body = <<-EOS
Client at #{remote_hostname} (#{env['REMOTE_ADDR']}) tried to get #{env['PATH_INFO']}

#{env['sinatra.error'].message}

#{env.to_a.sort{ |a,b| a.first <=> b.first }.map{ |k,v| "%-25s%p" % [k+':', v] }.join("\n  ")}
EOS
    notify("[#{Blog.title}] 500 Internal Server Error", body)
  end
  
  def expires_in(time)
    headers['Cache-Control'] = "public, max-age=#{time}"
  end
  
  def no_cache
    headers['Cache-Control'] = 'no-cache'
  end
  
  def update_twitter
    print "Running Twitter update...checking for posts...\n"
    Post.published.untwittered.all.each do |post|
      begin
        print "Starting Twitter update for '#{post.title}'\n"
        resp = RestClient.post('http://api.tr.im/v1/trim_url.json', :url => post_permaurl(post))
        resp = Crack::JSON.parse(resp)
        print "Parsed tr.im response\n"
        if resp['status']['code'] =~ /2\d\d/
          short_url = resp['url']
          httpauth = Twitter::HTTPAuth.new(Blog.twitter, Blog.twitter_password)
          client = Twitter::Base.new(httpauth)
          client.update("#{Blog.title}: #{post.title} #{short_url}")
          print "Finished Twitter update\n"
          post.update_attributes(:twittered => true)
        else
          notify('[verbose logging] Error with tr.im', resp['status']['message'])
        end
      rescue Exception => e
        body = <<-EOS
Error announcing '#{post.title}' on Twitter

#{e.message}
EOS
        notify("[verbose logging] Error posting to Twitter", body)
      end
    end
  end
end

use Rack::StaticCache, :urls => ['/images','/javascripts','/stylesheets','/favicon.ico','/sitemap.xsl','/swf'], :versioning => false, :root => 'public', :duration => 1/365
use Rack::RemoveSlash
use Rack::ETag

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
named_routes[:update_twitter] = '/update-twitter'
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
  redirect(fb_url, 301) unless env['HTTP_USER_AGENT'] =~ /feedburner/i
  @posts = Post.published.all(:limit => 10)
  content_type('application/rss+xml', :charset => 'utf-8')
  builder(:feed)
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
  published = params[:post][:published]
  params[:post][:published] = (published.nil? || 'false' == published) ? false : true
  if post = Post.create(params[:post])
    redirect("#{post.permalink}/edit")
  else
    redirect('/posts')
  end
end

# update existing post
named_route(:put, :posts) do
  no_cache
  require_administrative_privileges
  published = params[:post][:published]
  params[:post][:published] = (published.nil? || 'false' == published) ? false : true
  post = Post.find(params[:post].delete(:id))
  if post.published && params[:post].has_key?(:title) && post.title.parameterize != params[:post][:title].parameterize
    Redirection.create(:post => post, :old_permalink => post.permalink)
  end
  post.update_attributes(params[:post])
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
  r = Redirection.create(params[:redirection])
  content_type('application/xml')
  r.to_xml
end

# force update twitter
named_route(:post, :update_twitter) do
  no_cache
  require_administrative_privileges
  update_twitter
end

# admin index
named_route(:get, :admin_index) do
  no_cache
  require_administrative_privileges
  @posts = Post.unpublished.all
  haml(:admin_index, :layout => :admin)
end