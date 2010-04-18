# encoding: utf-8

require 'ostruct'
require 'bugzscout'
require 'social'
require 'archive_date'
require 'tzinfo'

require 'will_paginate'
require 'will_paginate/view_helpers'

WillPaginate::ViewHelpers.pagination_options[:container] = false
WillPaginate::ViewHelpers.pagination_options[:previous_label] = '← Previous'
WillPaginate::ViewHelpers.pagination_options[:next_label] = 'Next →'

require 'sinatra/authorization'
require 'sinatra/routing'
require 'sinatra/render'
require 'sinatra/bundles'

%w(etag head static_cache remove_slash inline_compress canonical_host response_time_injector bugzscout insert).each do |ext|
  require "rack/#{ext}"
end

%w(view_helpers utilities caching test).each do |helper|
  require "blog_helper/#{helper}"
end

require 'monkey_patch'

if development?
  begin
    require 'ruby-debug'
  rescue LoadError
  end
end

WillPaginate.enable_activerecord

WillPaginate::LinkRenderer.class_eval do
protected

  def url_for(page)
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