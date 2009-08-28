#!/Users/darkhelmet/local/ruby/bin/ruby

require 'rubygems'
require 'sinatra'
require 'activerecord'
require 'will_paginate' 
require 'will_paginate/view_helpers'
require 'acts_as_taggable'
require 'tags_helper'
require 'ostruct'

WillPaginate.enable_activerecord

WillPaginate::LinkRenderer.class_eval do
protected
  
  def url(page)
    debugger
    url = @template.request.url
    if 1 == page
      '/'
    else
      "/page/#{page}"
    end
  end
end

$: << File.expand_path(File.join('.', 'lib'))

require 'sinatra/authorization'
require 'models'

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
                        :delicious => ENV['BLOG_DELICIOUS'] || 'darkhelmetlive')
end

helpers do
  include Sinatra::Authorization
  include TagsHelper
  include WillPaginate::ViewHelpers
  
  def partial(page, options = {})
    haml(page, options.merge(:layout => false))
  end
  
  def stylesheet_link_tag(sheet, media = 'screen,projection')
    link = sheet.include?('http://') ? sheet : "/stylesheets/#{sheet}.css"
    partial("%link{ :type => 'text/css', :href => '#{link}', :rel => 'stylesheet', :media => '#{media}' }")
  end
  
  def javascript_include_tag(js)
    link = js.include?('http://') ? link : "/javascripts/#{js}.js"
    partial("%script{ :type => 'text/javascript', :src => '#{link}' }")
  end
  
  def title
    @title
  end
  
  def title=(t)
    @title = "#{Blog.title} | #{t}"
  end
  
  def fb_url
    "http://feeds.feedburner.com/#{Blog.feedburner}"
  end
end

# main index
get '/' do
  haml(:posts)
end

# rss feed
get '/feed' do
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