source 'http://gemcutter.org'

gem 'rack', '1.2.1'
gem 'sinatra', '1.0', :require => 'sinatra/base'
gem 'haml', '3.0.13'
gem 'builder', '2.1.2'
gem 'activesupport', '2.3.8', :require => 'active_support'
gem 'activerecord', '2.3.8', :require => 'active_record'
gem 'sinatra-bundles', '0.4.0', :require => 'sinatra/bundles'
gem 'rack-gist', '1.0.6', :require => 'rack/gist'
gem 'acts_as_taggable_on_steroids', '1.2', :require => nil
gem 'RedCloth', '4.2.2'
gem 'crack', '0.1.6'
gem 'rest-client', '1.6.0'
gem 'tzinfo', '0.3.16'
gem 'rainpress', '1.0.0'
gem 'packr', '3.1.0'
gem 'hpricot', '0.8.2'
gem 'sanitize', '1.2.0'
gem 'texticle', '1.0.2'
gem 'term_extraction', '0.1.7'
gem 'hashie', '0.1.8'
gem 'tilt', '1.0.1'
gem 'will_paginate', '2.3.12'
gem 'pg', '0.8.0'
gem 'newrelic_rpm', '2.10.5'

if 'darkhelmet' == ENV['USER']
  gem 'memcached', :path => '~/dev/github/fauna/memcached'
else
  gem 'memcached-northscale', '0.19.5.3', :require => 'memcached'
end

group :development do
  gem 'ruby-debug19'
end