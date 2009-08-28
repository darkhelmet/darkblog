class Post < ActiveRecord::Base
  belongs_to :redirection, :class_name => 'Post'
  validates_presence_of :title
  validates_presence_of :category
  
  acts_as_taggable
  
  default_scope(:order => 'published_on DESC', :published => false)
  named_scope(:published, :conditions => { :published => true })
  
  before_save do |record|
    record.slug = record.title.parameterize
    record.published_on  = Time.now unless record.published_on?
  end
  
  def body_html
    RedCloth.new(body.gsub("\r\n\r\n","\r\n<br />\r\n")).to_html
  end
  
  def matches_url(year,month,day)
    created_at.year == year && created_at.month == month && created_at.day
  end
end


env = ENV.has_key?('RACK_ENV') ? ENV['RACK_ENV'].to_sym : :development
CONFIG_FILE = File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'database.yml'))
CONFIG = YAML.load_file(CONFIG_FILE)
ActiveRecord::Base.establish_connection(CONFIG[env])