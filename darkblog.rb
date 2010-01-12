#!/usr/bin/env ruby

$KCODE = 'u' if RUBY_VERSION.match(/1\.8/)

$: << File.expand_path(File.join('.', 'lib'))

require 'rubygems'

# Load our own gems
Gem.clear_paths
ENV['GEM_HOME'] = File.expand_path(File.join(File.dirname(__FILE__), 'vendor'))

gem 'sinatra', '= 0.10.1'
require 'sinatra'
require 'blog_helper'

configure do
  Blog = OpenStruct.new(:title => ENV['BLOG_TITLE'] || 'verbose logging',
                        :tagline => ENV['BLOG_TAGLINE'] || 'programming, software development, and code',
                        :index => ENV['BLOG_INDEX'] || 'http://localhost:8080/',
                        :host => ENV['BLOG_HOST'] || 'blog.darkhax.com',
                        :email => ENV['BLOG_EMAIL'] || 'darkhelmet@darkhelmetlive.com',
                        :username => ENV['BLOG_USERNAME'] || 'darkhelmet',
                        :author => ENV['BLOG_AUTHOR'] || 'Daniel Huckstep',
                        :bio => ENV['BLOG_BIO'] || 'is a software engineer (EIT) in Edmonton, Alberta, Canada',
                        :feedburner => ENV['BLOG_FEEDBURNER'] || 'VerboseLogging',
                        :password => ENV['BLOG_PASSWORD'] || 'password',
                        :github => ENV['BLOG_GITHUB'] || 'darkhelmet',
                        :twitter => ENV['BLOG_TWITTER'] || 'darkhelmetlive',
                        :twitter_password => ENV['BLOG_TWITTER_PASSWORD'] || 'secret',
                        :delicious_user => ENV['BLOG_DELICIOUS_USER'] || 'darkhelmetlive',
                        :delicious_password => ENV['BLOG_DELICIOUS_PASSWORD'] || 'secret',
                        :reader_id => ENV['BLOG_READER_ID'] || '13098793136980097600',
                        :disqus => ENV['BLOG_DISQUS'] || 'verboselogging',
                        :per_page => ENV['BLOG_PER_PAGE'] || 10,
                        :tz => TZInfo::Timezone.get('America/Edmonton'),
                        :tz_display => 'MDT',
                        :fogbugz_host => ENV['BLOG_FOGBUGZ_HOST'] || 'darkhax.fogbugz.com',
                        :fogbugz_user => ENV['BLOG_FOGBUZ_USER'] || 'Daniel Huckstep',
                        :fogbugz_project => ENV['BLOG_FOGBUZ_PROJECT'] || 'darkhax',
                        :fogbugz_area => ENV['BLOG_FOGBUZ_AREA'] || 'Blog',
                        :yahoo_api_key => ENV['BLOG_YAHOO_API_KEY'] || nil,
                        :zemanta_api_key => ENV['BLOG_ZEMANTA_API_KEY'] || nil,
                        :user_agent => ENV['BLOG_USER_AGENT'] || 'verbose logging http://blog.darkhax.com/')
end

configure :production do
  not_found do
    not_found_notification
    haml(:not_found)
  end

  before do
    unless env['PATH_INFO'].matches_any_of?(*STATIC_PATHS)
      expires(10.minutes, :public, :must_revalidate) if env['REQUEST_METHOD'] =~ /GET|HEAD/
    end
  end

  enable(:compress_bundles)
  enable(:cache_bundles)
end

require 'models'
require 'middleware'

helpers do
  include TagsHelper
  include WillPaginate::ViewHelpers::Base
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

stylesheet_bundle(:all, %w(darkblog panel jquery.lightbox tipsy))
javascript_bundle(:all, %w(panel jquery.lightbox swfobject flowplayer jquery.tipsy jquery.darkhax))

# main index with pagination
get(:index) do |page|
  page ||= '1'
  page = page.to_i
  setup_top_panel
  @posts = Post.published.paginate(:page => page, :per_page => Blog.per_page)
  not_found('Not Found') if @posts.empty?
  @future_post = Post.future.last if 1 == page
  title("Page #{page}") if 1 < page
  haml(:posts)
end

# monthly archive with pagination
get(:monthly) do |year,month,page|
  page ||= '1'
  page = page.to_i
  setup_top_panel
  date = DateTime.strptime("#{year}-#{month}-1 #{Blog.tz_display}", '%F %Z')
  @posts = Post.published.monthly(date).paginate(:page => page, :per_page => Blog.per_page)
  not_found if @posts.empty?
  title(date.strftime('%B %Y'), page)
  haml(:posts)
end

# category index with pagination
get(:category) do |category,page|
  page ||= '1'
  page = page.to_i
  setup_top_panel
  @posts = Post.published.category(category).paginate(:page => page, :per_page => Blog.per_page)
  not_found if @posts.empty?
  title(category.capitalize, page)
  haml(:posts)
end

# rss feed
get(:feed) do
  no_cache
  if user_agent?(/feedburner/i) || development?
    @posts = Post.published.all(:limit => 10)
    content_type('application/rss+xml', :charset => 'utf-8')
    builder(:feed)
  else
    redirect(fb_url, 301)
  end
end

# search with pagination
get(:search) do |page|
  page ||= '1'
  page = page.to_i
  setup_top_panel
  if query = params['q']
    @posts = Post.published.search(query).paginate(:page => page, :per_page => Blog.per_page)
    return haml(:empty_search) if @posts.empty?
    title("Search '#{query}'")
    haml(:posts)
  else
    redirect('/')
  end
end

# sitemap
get(:sitemap) do |gzip|
  @posts = Post.published
  content_type('application/xml', :charset => 'utf-8')
  builder(:sitemap)
end

# google search
get(:google) do
  setup_top_panel
  haml(:page, :locals => { :page => :google })
end

# information pages
%w(about contact disclaimer).each do |page|
  get("/#{page}") do
    setup_top_panel
    title(page.capitalize)
    haml(:page, :locals => { :page => page.intern })
  end
end

# permalinks
get(:permalink) do |permalink|
  no_cache if request.xhr?
  setup_top_panel
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
  keywords_post(@posts.first)
  title(@posts.first.title)
  disqus_part('disqus_single')
  sharing(true)
  request.xhr? ? haml(:posts, :layout => false) : haml(:posts)
end

# tags with pagination
get(:tag) do |tag,page|
  page ||= '1'
  page = page.to_i
  setup_top_panel
  @posts = Post.published.find_tagged_with(tag, :match_all => true).paginate(:page => page, :per_page => Blog.per_page)
  not_found if @posts.empty?
  title(tag, page)
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
  require_administrative_privileges
  @posts = Post.perma(permalink).paginate(:page => 1, :per_page => Blog.per_page)
  title(@posts.first.title)
  disqus_part('disqus_single')
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
  individual_tweet(status_id).text
end