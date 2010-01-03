require File.join(File.dirname(__FILE__), '..', 'darkblog.rb')
require 'blueprints'
require 'fakeweb'
require 'rack/test'
require 'spec'
require 'spec/autorun'

# Include the Rack::Test helpers
Spec::Runner.configure do |conf|
  conf.include Rack::Test::Methods
end

set(:environment, :test)
disable(:run)
enable(:raise_errors)
disable(:logging)

# Don't allow net connections; do everything through FakeWeb
FakeWeb.register_uri(:get, 'http://github.com/api/v1/json/darkhelmet', :body => File.read('spec/github.json'), :content_type => 'application/json; charset=utf-8')
FakeWeb.register_uri(:get, 'http://search.twitter.com/search.json?q=from%3Adarkhelmetlive', :body => File.read('spec/twitter.json'), :content_type => 'application/json; charset=utf-8')
FakeWeb.register_uri(:get, 'https://darkhelmetlive:secret@api.del.icio.us/v1/posts/recent?count=8', :body => File.read('spec/delicious.xml'), :content_type => 'text/xml; charset=utf-8')
FakeWeb.allow_net_connect = false