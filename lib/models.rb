class Post < ActiveRecord::Base
  has_many :redirections
  
  validates_presence_of :title
  validates_presence_of :category
  
  acts_as_taggable
  
  default_scope(:order => 'published_on DESC', :include => :tags)
  named_scope(:published, lambda { { :conditions => ['published = ? AND published_on < ?', true, Time.now] } })
  named_scope(:category, lambda { |cat| { :conditions => { :category => cat.downcase } } })
  named_scope(:perma, lambda { |date,slug| { :limit => 1, :conditions => { :published_on => (date.beginning_of_day..date.end_of_day), :slug => slug } } })
  named_scope(:future, lambda { { :conditions => ['published = ? AND published_on > ?', true, Time.now] } })
  named_scope(:monthly, lambda { |date| { :conditions => { :published_on => date.beginning_of_month.beginning_of_day..date.end_of_month.end_of_day } } })
  
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

class Cache < ActiveRecord::Base
  serialize :value
  
  def self.get(key, max_age = 1.hour)
    item = Cache.first(:conditions => { :key => key })
    if block_given?
      if item.nil? || item.updated_at < max_age.ago
        begin
          value = yield
          Cache.put(key,value)
          value
        rescue Exception => e
          p e.message
          item.nil? ? nil : item.value
        end
      else
        item.value
      end
    else
      item.nil? ? nil : item.value
    end
  end
  
  def self.put(key,value)
    c = Cache.find_or_create_by_key(key)
    c.value = value
    c.save
    c.touch
  end
  
  def self.purge(key)
    if item = Cache.first(:conditions => { :key => key })
      item.destroy
    end
  end
end

class Redirection < ActiveRecord::Base
  belongs_to :post
end

env = ENV.has_key?('RACK_ENV') ? ENV['RACK_ENV'] : 'development'
CONFIG_FILE = File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'database.yml'))
CONFIG = YAML.load_file(CONFIG_FILE)
ActiveRecord::Base.establish_connection(CONFIG[env])