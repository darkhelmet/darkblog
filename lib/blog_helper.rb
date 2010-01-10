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

require 'monkey_patch'

%w(view_helpers utilities caching test).each do |helper|
  require "blog_helper/#{helper}"
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