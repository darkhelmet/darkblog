class Post < ActiveRecord::Base
  belongs_to :redirection, :class_name => 'Post'
  acts_as_taggable
end

env = ENV.has_key?('RACK_ENV') ? ENV['RACK_ENV'].to_sym : :development
CONFIG_FILE = File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'database.yml'))
CONFIG = YAML.load_file(CONFIG_FILE)
ActiveRecord::Base.establish_connection(CONFIG[env])