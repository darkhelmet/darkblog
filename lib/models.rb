class Post < ActiveRecord::Base
  validates_presence_of :title
  validates_presence_of :category
  
  acts_as_taggable
  
  default_scope(:order => 'published_on DESC', :include => :tags)
  named_scope(:published, lambda { { :conditions => ['published = ? AND published_on < ?', true, Time.now] } })
  named_scope(:category, lambda { |cat| { :conditions => { :category => cat.downcase } } })
  named_scope(:perma, lambda { |date,slug| { :limit => 1, :conditions => { :published_on => (date.beginning_of_day..date.end_of_day), :slug => slug } } })
  named_scope(:future, lambda { { :conditions => ['published = ? AND published_on > ?', true, Time.now] } })
  
  before_save do |record|
    record.slug = record.title.parameterize
    record.published_on  = Time.now unless record.published_on?
  end
  
  def category=(cat)
    write_attribute(:category, cat.downcase)
  end
  
  def body_html
    RedCloth.new(body).to_html
  end
end

env = ENV.has_key?('RACK_ENV') ? ENV['RACK_ENV'].to_sym : :development
CONFIG_FILE = File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'database.yml'))
CONFIG = YAML.load_file(CONFIG_FILE)
ActiveRecord::Base.establish_connection(CONFIG[env])