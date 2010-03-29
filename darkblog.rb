#!/usr/bin/env ruby

# We are ruby 1.9 only
Encoding.default_external = 'utf-8'
Encoding.default_internal = 'utf-8'

$: << File.expand_path(File.join('.', 'lib'))

begin
  # Require the preresolved locked set of gems.
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fallback on doing the resolve at runtime.
  require 'rubygems'
  begin
    require 'ruby-debug'
  rescue LoadError
  end
  require 'bundler'
  Bundler.setup
end

require 'sinatra'
Bundler.require

require 'blog_helper'

configure do
  Blog = OpenStruct.new(:title => ENV['BLOG_TITLE'] || 'Verbose Logging',
                        :tagline => ENV['BLOG_TAGLINE'] || 'software development with some really amazing hair',
                        :index => ENV['BLOG_INDEX'] || 'http://localhost:8080/',
                        :host => ENV['BLOG_HOST'] || 'blog.darkhax.com',
                        :email => ENV['BLOG_EMAIL'] || 'darkhelmet@darkhelmetlive.com',
                        :username => ENV['BLOG_USERNAME'] || 'darkhelmet',
                        :author => ENV['BLOG_AUTHOR'] || 'Daniel Huckstep',
                        :bio => ENV['BLOG_BIO'] || 'is a software engineer (EIT) in Edmonton, Alberta, Canada',
                        :feedburner => ENV['BLOG_FEEDBURNER'] || 'VerboseLogging',
                        :password => ENV['BLOG_PASSWORD'] || 'password',
                        :twitter => ENV['BLOG_TWITTER'] || 'darkhelmetlive',
                        :twitter_password => ENV['BLOG_TWITTER_PASSWORD'] || 'secret',
                        :disqus => ENV['BLOG_DISQUS'] || 'verboselogging',
                        :per_page => ENV['BLOG_PER_PAGE'] || 10,
                        :tz => TZInfo::Timezone.get('America/Edmonton'),
                        :tz_display => 'MDT',
                        :fogbugz_host => ENV['BLOG_FOGBUGZ_HOST'] || 'darkhax.fogbugz.com',
                        :fogbugz_user => ENV['BLOG_FOGBUZ_USER'] || 'Daniel Huckstep',
                        :fogbugz_project => ENV['BLOG_FOGBUZ_PROJECT'] || 'darkhax',
                        :fogbugz_area => ENV['BLOG_FOGBUZ_AREA'] || 'Blog',
                        :yahoo_api_key => ENV['BLOG_YAHOO_API_KEY'] || nil,
                        :user_agent => ENV['BLOG_USER_AGENT'] || 'verbose logging http://blog.darkhax.com/',
                        :google_analytics => ENV['BLOG_GOOGLE_ANALYTICS'] || 'UA-2062105-4',
                        :typekit_id => ENV['BLOG_TYPEKIT_ID'] || 'lml6ico',
                        :asset_host => ENV['BLOG_ASSET_HOST'] || 'static.verboselogging.com')
end

configure :production do
  not_found do
    not_found_notification
    haml(:not_found)
  end

  before do
    if env['REQUEST_METHOD'] =~ /GET|HEAD/
      expires(30.minutes, :public, :must_revalidate)
      headers('Vary' => 'Accept-Encoding')
    end
  end

  set(:haml, { :ugly => true })
end

require 'models'
require 'middleware'

helpers do
  include TagsHelper
  include WillPaginate::ViewHelpers
  include BlogHelper::ViewHelpers
  include BlogHelper::Utilities
  include BlogHelper::Caching
end

map(:index).to(%r|^/(?:page/(\d+))?$|)
map(:search).to(%r|^/search(?:/page/(\d+))?$|)
map(:monthly).to(%r|^/(\d{4})/(\d{2})(?:/page/(\d+))?$|)
map(:category).to(%r|^/category/(\w+)(?:/page/(\d+))?$|)
map(:feed).to(%r|^/feed.*|)
map(:sitemap).to(%r|^/sitemap.xml(.gz)?$|)
map(:open_search).to('/opensearch.xml')
map(:google).to('/google-search')
map(:permalink).to(%r|^(/\d{4}/\d{2}/\d{2}/[\w\d\-+ ]+)$|)
map(:short_permalink).to(%r|^/([\w\d\-+ ]+)$|)
map(:tag).to(%r|^/tag/([\w\-.]+)(?:/page/(\d+))?$|)
map(:edit_post).to(%r|^(/\d{4}/\d{2}/\d{2}/[\w\d\-+ ]+)/edit$|)
map(:preview_post).to(%r|^(/\d{4}/\d{2}/\d{2}/[\w\d\-+ ]+)/preview$|)
map(:posts).to('/posts')
map(:redirections).to('/redirections')
map(:announce).to('/announce')
map(:admin_index).to('/index')
map(:twitter).to('/twitter/:status')

stylesheet_bundle(:all, %w(panel facebox darkblog))
stylesheet_bundle(:admin, %w(panel facebox darkblog jquery.autocomplete markitup/style markitup/set))

javascript_bundle(:all, %w(panel facebox jaml jquery.timeago templates jquery.darkblog darkcoffee))
javascript_bundle(:admin, %w(panel facebox jaml jquery.timeago jquery.autocomplete jquery.markitup set templates jquery.darkblog darkcoffee))

# main index with pagination
get(:index) do |page|
  redirect(Blog.index, 301) if 1 == page.to_s.to_i
  page = get_page(page)
  @posts = Post.published.paginate(:page => page, :per_page => Blog.per_page)
  not_found('Not Found') if @posts.empty?
  @future_post = Post.future.last if 1 == page
  title("Page #{page}") if 1 < page
  canonical(build_can('', page))
  description(Blog.tagline, page)
  haml(:posts)
end

# monthly archive with pagination
get(:monthly) do |year, month, page|
  can = build_can("#{year}/#{month}", page)
  redirect(can) if 1 == page.to_s.to_i
  page = get_page(page)
  date = DateTime.strptime("#{year}-#{month}-1 #{Blog.tz_display}", '%F %Z')
  @posts = Post.published.monthly(date).paginate(:page => page, :per_page => Blog.per_page)
  not_found if @posts.empty?
  title(date.strftime('%B %Y'), page)
  canonical(can)
  description("#{Blog.title} archives for #{date.strftime('%B')} #{year}", page)
  haml(:posts)
end

# category index with pagination
get(:category) do |category, page|
  can = build_can("category/#{category}", page)
  redirect(can, 301) if 1 == page.to_s.to_i
  page = get_page(page)
  @posts = Post.published.category(category).paginate(:page => page, :per_page => Blog.per_page)
  not_found if @posts.empty?
  title(category.capitalize, page)
  canonical(can)
  description("#{Blog.title} archives in the #{category.capitalize} category", page)
  haml(:posts)
end

# rss feed
get(:feed) do
  no_cache
  redirect(fb_url, 301) unless user_agent?(/feedburner/i) || development?
  @posts = Post.published.all(:limit => 10)
  content_type('application/rss+xml', :charset => 'utf-8')
  builder(:feed)
end

# search with pagination
get(:search) do |page|
  page = get_page(page)
  query = params['q']
  redirect('/') unless query
  @posts = Post.published.search(query).paginate(:page => page, :per_page => Blog.per_page)
  description("#{Blog.title} search results for '#{query}'", page)
  return haml(:empty_search) if @posts.empty?
  title("Search '#{query}'")
  haml(:posts)
end

# sitemap
get(:sitemap) do |gzip|
  @posts = Post.published
  content_type('application/xml', :charset => 'utf-8')
  builder(:sitemap)
end

get(:open_search) do
  content_type('application/opensearchdescription+xml', :charset => 'utf-8')
  builder(:open_search)
end

# google search
get(:google) do
  enable_minimal_sidebar
  canonical(build_can('google-search'))
  description("Google Search for #{Blog.title}")
  haml(:page, :locals => { :page => :google })
end

# information pages
{
  'about' => "About #{Blog.title}",
  'contact' => "Contact #{Blog.author}, the author of #{Blog.title}",
  'disclaimer' => "Disclaimer for #{Blog.title}",
  'talks' => "Talks the author, #{Blog.author} has done",
  'changelog' => "Recent commits to the source of of #{Blog.title}"
}.each do |page, desc|
  get("/#{page}") do
    enable_minimal_sidebar
    title(page.capitalize)
    canonical(build_can(page))
    description(desc)
    haml(:page, :locals => { :page => page.intern })
  end
end

# permalinks
get(:permalink) do |permalink|
  no_cache if request.xhr?
  disable_post_preview
  @posts = Post.published.perma(permalink).paginate(:page => 1, :per_page => 1)
  if @posts.empty?
    r = Redirection.first(:conditions => { :old_permalink => permalink })
    r.nil? ? not_found : redirect(r.post.permalink, 301)
  end
  keywords_post(@posts.first)
  title(@posts.first.title)
  disqus_single
  enable_sharing
  canonical(post_permaurl(@posts.first))
  description(@posts.first.description)
  request.xhr? ? haml(:posts, :layout => false) : haml(:posts)
end

# tags with pagination
get(:tag) do |tag, page|
  can = build_can("tag/#{tag}", page)
  redirect(can, 301) if 1 == page.to_s.to_i
  page = get_page(page)
  @posts = Post.published.find_tagged_with(tag, :match_all => true).paginate(:page => page, :per_page => Blog.per_page)
  not_found if @posts.empty?
  title(tag, page)
  canonical(can)
  description("#{Blog.title} archives tagged with '#{tag}'", page)
  haml(:posts)
end

# edit post
get(:edit_post) do |permalink|
  no_cache
  require_administrative_privileges
  @post = Post.perma(permalink).first
  title("Editing '#{@post.title}'")
  haml(:edit_post, :layout => :admin)
end

# preview post
get(:preview_post) do |permalink|
  no_cache
  disable_post_preview
  require_administrative_privileges
  @posts = Post.perma(permalink).paginate(:page => 1, :per_page => Blog.per_page)
  redirect('/index') if @posts.empty?
  title(@posts.first.title)
  disqus_single
  haml(:posts)
end

# new post
get(:posts) do
  no_cache
  require_administrative_privileges
  @post = Post.new
  title('New Post')
  haml(:edit_post, :layout => :admin)
end

# create new post
post(:posts) do
  no_cache
  require_administrative_privileges
  published = params['post']['published']
  params['post']['published'] = (published.nil? || 'false' == published) ? false : true
  if post = Post.create(params['post'])
    rebuild_sidebar
    redirect("#{post.permalink}/edit")
  else
    redirect('/posts')
  end
end

# update existing post
put(:posts) do
  no_cache
  require_administrative_privileges
  published = params['post']['published']
  params['post']['published'] = (published.nil? || 'false' == published) ? false : true
  post = Post.find(params['post'].delete('id'))
  if post.published && params['post'].has_key?('title') && post.title.parameterize != params['post']['title'].parameterize
    Redirection.create(:post => post, :old_permalink => post.permalink)
  end
  post.update_attributes(params['post'])
  rebuild_sidebar
  redirect("#{post.permalink}/edit")
end

# redirection form
get(:redirections) do
  no_cache
  require_administrative_privileges
  haml(:edit_redirection, :layout => :admin)
end

# create redirection
post(:redirections) do
  no_cache
  require_administrative_privileges
  r = Redirection.create(params['redirection'])
  content_type('application/xml')
  r.to_xml
end

post(:announce) do
  no_cache
  require_administrative_privileges
  announce unless Post.published.unannounced.all.each(&:announce).empty?
  ''
end

# admin index
get(:admin_index) do
  no_cache
  require_administrative_privileges
  @posts = Post.unpublished.all
  haml(:admin_index, :layout => :admin)
end

get(:short_permalink) do |title|
  @posts = Post.published.ptitle(title)
  not_found if @posts.empty?
  redirect(@posts.first.permalink, 301)
end

# get twitter statuses
get(:twitter) do |status_id|
  expires(1.day, :public, :must_revalidate)
  content_type('text/plain')
  tweet = individual_tweet(status_id)
  "@#{tweet.user.screen_name} said: #{tweet.text}"
end

delete(:permalink) do |permalink|
  no_cache
  require_administrative_privileges
  post = Post.perma(permalink).first
  post.destroy
  rebuild_sidebar
  content_type('application/javascript')
  "window.location = '#{Blog.index}index'"
end

get '/dump.json' do
  no_cache
  require_administrative_privileges
  content_type('application/json', :charset => 'utf-8')
  all = {}
  ActiveRecord::Base.send(:subclasses).each do |klass|
    all.merge!({ klass.table_name => klass.all })
  end
  all.to_json
end