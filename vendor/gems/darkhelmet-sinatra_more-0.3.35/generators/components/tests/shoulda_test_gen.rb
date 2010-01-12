module Sinatra
  module ShouldaTestGen
    SHOULDA_SETUP = <<-TEST
\nclass Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    CLASS_NAME.tap { |app| app.set :environment, :test }
  end
end
TEST

    def setup_test
      require_dependencies 'test/unit', 'shoulda', :env => :testing
      insert_test_suite_setup SHOULDA_SETUP
    end
    
  end
end