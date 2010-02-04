require 'active_record'
require 'texticle'

ActiveRecord::Base.extend(Texticle)

%w(post cache redirection keyword keywording).each do |model|
  require "models/#{model}"
end

Tag.destroy_unused = true

RACK_ENV = ENV.has_key?('RACK_ENV') ? ENV['RACK_ENV'] : 'development'
DB_CONFIG_FILE = File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'database.yml'))
DB_CONFIG = YAML.load_file(DB_CONFIG_FILE)
ActiveRecord::Base.establish_connection(DB_CONFIG[RACK_ENV])
ActiveRecord::Base.default_timezone = :utc