#!/Users/darkhelmet/local/ruby/bin/ruby

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
%w(acts_as_taggable tag tag_list tagging tags_helper).each { |lib| require lib }
require 'ostruct'
require 'RedCloth'
require 'aws/s3'
require 'octopi'
require 'twitter'
require 'www/delicious'
require 'feedzirra'
require 'sinatra/authorization'
require 'ruby-debug'

ActiveRecord::Base.logger = Logger.new('db.log')

WillPaginate::ViewHelpers::LinkRenderer.class_eval do
protected
  
  def url(page)
    path = @template.request.path
    case path
    when /tags?|category/
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
                        :email => ENV['BLOG_EMAIL'] || 'darkhelmet@darkhelmetlive.com',
                        :author => ENV['BLOG_AUTHOR'] || 'Daniel Huckstep',
                        :bio => ENV['BLOG_BIO'] || 'is a software engineer (EIT) in Edmonton, Alberta, Canada',
                        :feedburner => ENV['BLOG_FEEDBURNER'] || 'VerboseLogging',
                        :password => ENV['BLOG_PASSWORD'] || 'password',
                        :github => ENV['BLOG_GITHUB'] || 'darkhelmet',
                        :twitter => ENV['BLOG_TWITTER'] || 'darkhelmetlive',
                        :delicious_user => ENV['BLOG_DELICIOUS_USER'] || 'darkhelmetlive',
                        :delicious_password => ENV['BLOG_DELICIOUS_PASSWORD'] || 'secret',
                        :reader_id => ENV['BLOG_READER_ID'] || '13098793136980097600',
                        :s3_access => ENV['BLOG_S3_ACCESS_KEY'] || 'secret',
                        :s3_secret => ENV['BLOG_S3_SECRET_KEY'] || 'secret',
                        :s3_bucket => ENV['BLOG_S3_BUCKET'] || 's3.blog.darkhax.com',
                        :per_page => ENV['BLOG_PER_PAGE'] || 10)
end

before do 
  params.symbolize_keys!
  params.each do |k,v|
    v.symbolize_keys!
  end
  @tags = Post.tag_counts
  setup_top_panel
end

require 'models'

helpers do
  include Sinatra::Authorization
  include TagsHelper
  include WillPaginate::ViewHelpers::Base
  
  def partial(page, options = {})
    haml(page, options.merge(:layout => false))
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
  
  def title(t = nil)
    if t.nil?
      @title || Blog.title
    else
      @title = "#{Blog.title} | #{t}"
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
  
  def post_permalink(post)
    "/#{post.published_on.strftime('%Y/%m/%d')}/#{post.slug}"
  end
  
  def post_permaurl(post)
    Blog.index + post_permalink(post).split('/').reject(&:blank?).join('/')
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
    oldest = Post.published.last
    year = oldest.published_on.year
    month = oldest.published_on.month
    
    links = Array.new
    while year <= newest.published_on.year && month <= newest.published_on.month
      date = Date.new(year,month,1)
      links << partial("%a{ :href => '/#{date.strftime('%Y/%m')}' } #{date.strftime('%B %Y')}")
      year, month = next_month(year,month)
    end
    links
  end
  
  def setup_top_panel
    # @repos = Cache.get('github', 1.day) do
    #       Octopi::User.find(Blog.github).repositories
    #     end
    
    @tweets = Cache.get('twitter', 10.minutes) do
      p 'GETTING TWITTER'
      Twitter::Search.new.from(Blog.twitter).to_a[0,6]
    end
    
    @bookmarks = Cache.get('delicious', 1.hour) do 
      p 'GETTING DELICIOUS'
      WWW::Delicious.new(Blog.delicious_user, Blog.delicious_password).posts_recent[0,6]
    end
    
    @shared_items = Cache.get('reader', 6.hours) do
      p 'GETTING SHARED ITEMS'
      Feedzirra::Feed.fetch_and_parse("http://www.google.com/reader/public/atom/user/#{Blog.reader_id}/state/com.google/broadcast").entries[0,6]
    end
  end
  
  def tweet(t)
    t.text
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
    partial("%a{ :href => '#{s.links.first}' } #{s.title}")
  end
end

# main index
get '/' do
  @posts = Post.published.paginate(:page => 1, :per_page => Blog.per_page)
  @future_post = Post.future.last
  haml(:posts)
end

# pagination
get %r|^/page/(\d+)$| do |page|
  @posts = Post.published.paginate(:page => page.to_i, :per_page => Blog.per_page)
  title("Page #{page}")
  haml(:posts)
end

# monthly archive
get %r|^/(\d{4})/(\d{2})$| do |year,month|
  date = Date.new(year.to_i, month.to_i, 1)
  @posts = Post.published.monthly(date).paginate(:page => 1, :per_page => Blog.per_page)
  title(date.strftime('%B %Y'))
  haml(:posts)
end

# monthly archive with pagination
get %r|^/(\d{4})/(\d{2})/page/(\d+)$| do |year,month,page|
  date = Date.new(year.to_i, month.to_i, 1)
  @posts = Post.published.monthly(date).paginate(:page => page.to_i, :per_page => Blog.per_page)
  title("#{date.strftime('%B %Y')} page #{page}")
  haml(:posts)
end

# category index
get '/category/:category' do |category|
  @posts = Post.published.category(category).paginate(:page => 1, :per_page => Blog.per_page)
  title(category)
  haml(:posts)
end

get %r|^/category/(\w)/page/(\d+)$| do |category,page|
  @posts = Post.published.category(category).paginate(:page => page.to_i, :per_page => Blog.per_page)
  title("#{category} page #{page}")
  haml(:posts)
end

# rss feed
get '/feed' do
  redirect(fb_url, 301) unless request.env['HTTP_USER_AGENT'] =~ /feedburner/i
  @posts = Post.published.all(:limit => 10)
  content_type('application/rss+xml', :charset => 'utf-8')
  builder(:feed)
end

get %r|^/sitemap.xml(.gz)?$| do |gzip|
  'TODO: sitemap'
end

get '/google-search' do
  haml(:page, :locals => { :page => :google })
end

%w(about contact disclaimer).each do |page|
  get "/#{page}" do
    title(page.capitalize)
    haml(:page, :locals => { :page => page.intern })
  end
end

# permalinks
get %r|^/(\d{4})/(\d{2})/(\d{2})/(.*)$| do |year,month,day,slug|
  @posts = Post.published.perma(Date.new(year.to_i, month.to_i, day.to_i), slug).paginate(:page => 1, :per_page => 1)
  title(@posts.first.title)
  request.xhr? ? haml(:posts, :layout => false) : haml(:posts)
end

# tags
get '/tags?/:tags' do |tags|
  @posts = Post.published.find_tagged_with(tags.gsub(' ',','), :match_all => true).paginate(:page => 1, :per_page => Blog.per_page)
  title(tags)
  haml(:posts)
end

get %r|^/tags?/([\w+]+)/page/(\d+)$| do |tags,page|
  @posts = Post.published.find_tagged_with(tags.gsub(' ',','), :match_all => true).paginate(:page => page.to_i, :per_page => Blog.per_page)
  title("#{tags} page #{page}")
  haml(:posts)
end

post '/posts' do
  params[:post][:published] = 'true' == params[:post][:published] ? true : false
  post = Post.create(params[:post])
  post.to_json(:except => [:created_at,:updated_at], :methods => :tag_list)
end

put '/posts' do
  Post.find(params[:post][:id]).update_attributes(params[:post])
end

post '/uploads' do
  upload = params[:upload][:data]
  AWS::S3::Base.establish_connection!(:access_key_id => Blog.s3_access, :secret_access_key => Blog.s3_secret)
  date = Date.today
  obj = AWS::S3::S3Object.store("/uploads/#{date.strftime('%Y/%m')}/#{upload[:filename]}",
                          upload[:tempfile],
                          Blog.s3_bucket,
                          :content_type => upload[:type],
                          :access => :public_read)
  "#{obj.response.code} #{obj.response.message}\n"
end