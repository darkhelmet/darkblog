module Sinatra
  module RrMockGen
    def setup_mock
      require_dependencies 'rr', :env => :testing
      insert_mocking_include "RR::Adapters::RRMethods", :path => "test/test_config.rb"
    end
  end
end