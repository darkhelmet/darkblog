#!/Users/darkhelmet/local/ruby/bin/ruby

$KCODE = 'u'

$: << File.expand_path(File.join('.', 'lib'))

require 'rubygems'
require 'sinatra'
require 'haml'
require 'activerecord'
require 'activesupport'
require 'will_paginate'
require 'will_paginate/finders/active_record'
require 'will_paginate/view_helpers/base'
require 'will_paginate/view_helpers/link_renderer'
%w(acts_as_taggable tag tag_list tagging tags_helper).each { |lib| require lib }
require 'ostruct'
require 'RedCloth'
require 'sinatra/authorization'
require 'models'

WillPaginate::ViewHelpers::LinkRenderer.class_eval do
protected
  
  def url(page)
    url = request.url
    if 1 == page
      '/'
    else
      "/page/#{page}"
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
                        :delicious => ENV['BLOG_DELICIOUS'] || 'darkhelmetlive',
                        :per_page => ENV['BLOG_PER_PAGE'] || 10)
end

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
  
  def title
    @title || Blog.title
  end
  
  def title=(t)
    @title = "#{Blog.title} | #{t}"
  end
  
  def fb_url
    "http://feeds.feedburner.com/#{Blog.feedburner}"
  end
  
  def gravatar_url(email)
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}"
  end
  
  def tag_link(tag)
    partial("%a{ :href => '/tags/#{tag}', :rel => 'tag' } tag")
  end
  
  def tag_links(post)
    post.tag_list.map { |tag| tag_link(tag) }.join(' ')
  end
  
  def post_class(post)
    post.tag_list.map { |tag| "tag-#{tag}" } | ['post', "post-#{post.id}", "category-#{post.category}"]
  end
  
  def post_permalink(post)
    "/#{post.published_on.strftime('%y/%m/%d')}/#{post.slug}"
  end
end

# main index
get '/' do
  @posts = Post.paginate(:page => 1, :per_page => Blog.per_page)
  haml(:posts)
end

# rss feed
get '/feed' do
end

get '/google-search' do
  haml(:page, :locals => { :page => :google })
end

%w(about contact disclaimer).each do |page|
  get "/#{page}" do
    haml(:page, :locals => { :page => page.intern })
  end
end

# pagination
get %r|/page/(\d+)| do |page|
  "Found page #{page}"
end

# permalinks
get %r|/(\d{4})/(\d{2})/(\d{2})/(\w+)| do |year,month,day,slug|
  "Got permalink #{year} #{month} #{day} #{slug}"
end

# tags
get '/tags/:tags' do |tags|
  "Got tags #{tags.gsub(' ', ', ')}"
end