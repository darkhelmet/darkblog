require 'helper'
require 'thor'
require File.dirname(__FILE__) + "/../../generators/skeleton_generator"

class TestSkeletonGenerator < Test::Unit::TestCase
  def setup
    `rm -rf /tmp/sample_app`
  end

  context 'the skeleton generator' do
    should "allow simple generator to run and create base_app with no options" do
      assert_nothing_raised { silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp', '--script=none']) } }
      assert File.exist?('/tmp/sample_app')
      assert File.exist?('/tmp/sample_app/config/dependencies.rb')
      assert File.exist?('/tmp/sample_app/test/test_config.rb')
    end
    should "create components file containing options chosen with defaults" do
      silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp']) }
      components_chosen = YAML.load_file('/tmp/sample_app/.components')
      assert_equal 'datamapper', components_chosen[:orm]
      assert_equal 'bacon', components_chosen[:test]
      assert_equal 'mocha', components_chosen[:mock]
      assert_equal 'jquery', components_chosen[:script]
      assert_equal 'erb', components_chosen[:renderer]
    end
    should "create components file containing options chosen" do
      component_options = ['--orm=datamapper', '--test=riot', '--mock=mocha', '--script=prototype', '--renderer=erb']
      silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp', *component_options]) }
      components_chosen = YAML.load_file('/tmp/sample_app/.components')
      assert_equal 'datamapper', components_chosen[:orm]
      assert_equal 'riot',  components_chosen[:test]
      assert_equal 'mocha',     components_chosen[:mock]
      assert_equal 'prototype', components_chosen[:script]
      assert_equal 'erb',   components_chosen[:renderer]
    end
    should "output to log components being applied" do
      component_options = ['--orm=datamapper', '--test=riot', '--mock=mocha', '--script=prototype', '--renderer=erb']
      buffer = silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp', *component_options]) }
      assert_match /Applying.*?datamapper.*?orm/, buffer
      assert_match /Applying.*?riot.*?test/, buffer
      assert_match /Applying.*?mocha.*?mock/, buffer
      assert_match /Applying.*?prototype.*?script/, buffer
      assert_match /Applying.*?erb.*?renderer/, buffer
    end
    should "output gem files for base app" do
      silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp', '--script=none']) }
      assert_match_in_file(/gem 'sinatra'/, '/tmp/sample_app/Gemfile')
      assert_match_in_file(/gem 'sinatra_more'/, '/tmp/sample_app/Gemfile')
      assert_match_in_file(/gem 'rack-flash'/, '/tmp/sample_app/Gemfile')
      assert_match_in_file(/gem 'rack-test'/, '/tmp/sample_app/Gemfile')
    end
  end

  context "a generator for mock component" do
    should "properly generate for rr" do
      buffer = silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp', '--mock=rr', '--script=none']) }
      assert_match /Applying.*?rr.*?mock/, buffer
      assert_match_in_file(/gem 'rr'/, '/tmp/sample_app/Gemfile')
      assert_match_in_file(/class.*?include RR::Adapters::RRMethods/m, '/tmp/sample_app/test/test_config.rb')
    end

    should "properly generate default for mocha" do
      buffer = silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp', '--mock=mocha', '--script=none']) }
      assert_match /Applying.*?mocha.*?mock/, buffer
      assert_match_in_file(/gem 'mocha'/, '/tmp/sample_app/Gemfile')
      assert_match_in_file(/class.*?include Mocha::API/m, '/tmp/sample_app/test/test_config.rb')
    end
  end


  context "the generator for orm components" do
    should "properly generate for sequel" do
      Sinatra::SkeletonGenerator.instance_eval("undef setup_orm if respond_to?('setup_orm')")
      buffer = silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp', '--orm=sequel', '--script=none']) }
      assert_match /Applying.*?sequel.*?orm/, buffer
      assert_match_in_file(/gem 'sequel'/, '/tmp/sample_app/Gemfile')
      assert_match_in_file(/SequelInitializer/, '/tmp/sample_app/config/initializers/sequel.rb')
      assert_match_in_file(/class User < Sequel::Model/, '/tmp/sample_app/app/models/user.rb')
    end

    should "properly generate for activerecord" do
      buffer = silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp', '--orm=activerecord', '--script=none']) }
      assert_match /Applying.*?activerecord.*?orm/, buffer
      assert_match_in_file(/gem 'activerecord'/, '/tmp/sample_app/Gemfile')
      assert_match_in_file(/ActiveRecordInitializer/, '/tmp/sample_app/config/initializers/active_record.rb')
      assert_match_in_file(/Migrate the database/, '/tmp/sample_app/Rakefile')
      assert_match_in_file(/CreateUsers < ActiveRecord::Migration/, '/tmp/sample_app/db/migrate/001_create_users.rb')
      assert_match_in_file(/class User < ActiveRecord::Base/, '/tmp/sample_app/app/models/user.rb')
    end

    should "properly generate default for datamapper" do
      buffer = silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp', '--orm=datamapper', '--script=none']) }
      assert_match /Applying.*?datamapper.*?orm/, buffer
      assert_match_in_file(/gem 'dm-core'/, '/tmp/sample_app/Gemfile')
      assert_match_in_file(/DataMapperInitializer/, '/tmp/sample_app/config/initializers/data_mapper.rb')
      assert_match_in_file(/class User.*?include DataMapper::Resource/m, '/tmp/sample_app/app/models/user.rb')
    end

    should "properly generate for mongomapper" do
      buffer = silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp', '--orm=mongomapper', '--script=none']) }
      assert_match /Applying.*?mongomapper.*?orm/, buffer
      assert_match_in_file(/gem 'mongo_mapper'/, '/tmp/sample_app/Gemfile')
      assert_match_in_file(/MongoDbInitializer/, '/tmp/sample_app/config/initializers/mongo_db.rb')
      assert_match_in_file(/class User.*?include MongoMapper::Document/m, '/tmp/sample_app/app/models/user.rb')
    end

    should "properly generate for couchrest" do
      buffer = silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp', '--orm=couchrest', '--script=none']) }
      assert_match /Applying.*?couchrest.*?orm/, buffer
      assert_match_in_file(/gem 'couchrest'/, '/tmp/sample_app/Gemfile')
      assert_match_in_file(/CouchRestInitializer/, '/tmp/sample_app/config/initializers/couch_rest.rb')
      assert_match_in_file(/class User < CouchRest::ExtendedDocument/m, '/tmp/sample_app/app/models/user.rb')      
    end
  end

  context "the generator for renderer component" do
    should "properly generate default for erb" do
      buffer = silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp', '--renderer=erb', '--script=none']) }
      assert_match /Applying.*?erb.*?renderer/, buffer
      assert_match_in_file(/gem 'erubis'/, '/tmp/sample_app/Gemfile')
    end

    should "properly generate for haml" do
      buffer = silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp', '--renderer=haml','--script=none']) }
      assert_match /Applying.*?haml.*?renderer/, buffer
      assert_match_in_file(/gem 'haml'/, '/tmp/sample_app/Gemfile')
      assert_match_in_file(/SassInitializer/, '/tmp/sample_app/config/initializers/sass.rb')
      assert_match_in_file(/app.use Sass::Plugin::Rack/, '/tmp/sample_app/config/initializers/sass.rb')
    end
  end

  context "the generator for script component" do
    should "properly generate for jquery" do
      buffer = silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp', '--script=jquery']) }
      assert_match /Applying.*?jquery.*?script/, buffer
      assert File.exist?('/tmp/sample_app/public/javascripts/jquery.min.js')
    end

    should "properly generate for prototype" do
      buffer = silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp', '--script=prototype']) }
      assert_match /Applying.*?prototype.*?script/, buffer
      assert File.exist?('/tmp/sample_app/public/javascripts/prototype.js')
      assert File.exist?('/tmp/sample_app/public/javascripts/lowpro.js')
    end

    should "properly generate for rightjs" do
      buffer = silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp', '--script=rightjs']) }
      assert_match /Applying.*?rightjs.*?script/, buffer
      assert File.exist?('/tmp/sample_app/public/javascripts/right-min.js')
      assert File.exist?('/tmp/sample_app/public/javascripts/right-olds-min.js')
    end
  end

  context "the generator for test component" do
    should "properly default generate for bacon" do
      buffer = silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp', '--test=bacon', '--script=none']) }
      assert_match /Applying.*?bacon.*?test/, buffer
      assert_match_in_file(/gem 'bacon'/, '/tmp/sample_app/Gemfile')
      assert_match_in_file(/Bacon::Context/, '/tmp/sample_app/test/test_config.rb')
    end

    should "properly generate for riot" do
      buffer = silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp', '--test=riot', '--script=none']) }
      assert_match /Applying.*?riot.*?test/, buffer
      assert_match_in_file(/gem 'riot'/, '/tmp/sample_app/Gemfile')
      assert_match_in_file(/Riot::Situation/, '/tmp/sample_app/test/test_config.rb')
    end

    should "properly generate for rspec" do
      buffer = silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp', '--test=rspec', '--script=none']) }
      assert_match /Applying.*?rspec.*?test/, buffer
      assert_match_in_file(/gem 'rspec', :require_as => "spec"/, '/tmp/sample_app/Gemfile')
      assert_match_in_file(/Spec::Runner/, '/tmp/sample_app/test/test_config.rb')
    end

    should "properly generate for shoulda" do
      buffer = silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp', '--test=shoulda', '--script=none']) }
      assert_match /Applying.*?shoulda.*?test/, buffer
      assert_match_in_file(/gem 'shoulda'/, '/tmp/sample_app/Gemfile')
      assert_match_in_file(/Test::Unit::TestCase/, '/tmp/sample_app/test/test_config.rb')
    end

    should "properly generate for testspec" do
      buffer = silence_logger { Sinatra::SkeletonGenerator.start(['sample_app', '/tmp', '--test=testspec', '--script=none']) }
      assert_match /Applying.*?testspec.*?test/, buffer
      assert_match_in_file(/gem 'test\/spec'/, '/tmp/sample_app/Gemfile')
      assert_match_in_file(/Test::Unit::TestCase/, '/tmp/sample_app/test/test_config.rb')
    end
  end
end
