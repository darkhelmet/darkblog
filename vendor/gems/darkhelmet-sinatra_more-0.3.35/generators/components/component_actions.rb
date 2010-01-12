module Sinatra
  module ComponentActions
    # Adds all the specified gems into the Gemfile for bundler
    # require_dependencies 'activerecord'
    # require_dependencies 'mocha', 'bacon', :env => :testing
    def require_dependencies(*gem_names)
      options = gem_names.extract_options!
      gem_names.reverse.each { |lib| insert_into_gemfile(lib, options) }
    end

    # Inserts a required gem into the Gemfile to add the bundler dependency
    # insert_into_gemfile(name)
    # insert_into_gemfile(name, :env => :testing)
    def insert_into_gemfile(name, options={})
      after_pattern = "# Component requirements\n"
      after_pattern = "# #{options[:env].to_s.capitalize} requirements\n" if environment = options[:env]
      include_text = "gem '#{name}'" 
      include_text << ", :require_as => #{options[:require_as].inspect}" if options[:require_as]
      include_text << ", :only => #{environment.inspect}" if environment
      include_text << "\n"
      options.merge!(:content => include_text, :after => after_pattern)
      inject_into_file('Gemfile', options[:content], :after => options[:after])
    end

    # Injects the test class text into the test_config file for setting up the test gen
    # insert_test_suite_setup('...CLASS_NAME...')
    # => inject_into_file("test/test_config.rb", TEST.gsub(/CLASS_NAME/, @class_name), :after => "set :environment, :test\n")
    def insert_test_suite_setup(suite_text, options={})
      options.reverse_merge!(:path => "test/test_config.rb", :after => /Test configuration\n/)
      inject_into_file(options[:path], suite_text.gsub(/CLASS_NAME/, @class_name), :after => options[:after])
    end

    # Injects the mock library include into the test class in test_config for setting up mock gen
    # insert_mock_library_include('Mocha::API')
    # => inject_into_file("test/test_config.rb", "  include Mocha::API\n", :after => /class.*?\n/)
    def insert_mocking_include(library_name, options={})
      options.reverse_merge!(:indent => 2, :after => /class.*?\n/, :path => "test/test_config.rb")
      include_text = indent_spaces(options[:indent]) + "include #{library_name}\n"
      inject_into_file(options[:path], include_text, :after => options[:after])
    end

    # Returns space characters of given count
    # indent_spaces(2)
    def indent_spaces(count)
      ' ' * count
    end
  end
end
