require 'active_record'

if development?
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

require 'texticle'

ActiveRecord::Base.extend(Texticle)

require 'acts_as_taggable_on_steroids'
require 'tag'
require 'tag_list'
require 'tagging'
require 'tags_helper'

%w(post cache redirection keyword keywording).each do |model|
  require "models/#{model}"
end

Tag.destroy_unused = true

RACK_ENV = ENV.has_key?('RACK_ENV') ? ENV['RACK_ENV'] : 'development'
DB_CONFIG_FILE = File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'database.yml'))
DB_CONFIG = YAML.load_file(DB_CONFIG_FILE)
ActiveRecord::Base.establish_connection(DB_CONFIG[RACK_ENV])
ActiveRecord::Base.default_timezone = :utc

ActiveRecord::Base.send(:subclasses).each do |klass|
  klass.columns_hash.each do |column_name,column|
    if [:string, :text].include?(column.type)
      klass.send(:define_method, column_name) do
        returning(read_attribute(column_name)) do |value|
          value.force_encoding('utf-8') if value.respond_to?(:force_encoding)
        end
      end
    end
  end
end