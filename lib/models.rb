class Post < ActiveRecord::Base
  has_many :redirections

  index do
    title
    category
    body
    cached_tag_list
  end

  validates_presence_of :title
  validates_presence_of :category

  acts_as_taggable

  default_scope(:order => 'published_on DESC', :include => :tags)
  named_scope(:published, lambda { { :conditions => ['published = ? AND published_on < ?', true, Time.now.utc] } })
  named_scope(:unpublished, :conditions => { :published => false })
  named_scope(:category, lambda { |cat| { :conditions => { :category => cat.downcase } } })
  named_scope(:perma, lambda { |perma| { :limit => 1, :conditions => { :permalink => perma.gsub(' ', '+') } } })
  named_scope(:future, lambda { { :conditions => ['published = ? AND published_on > ?', true, Time.now.utc] } })
  named_scope(:monthly, lambda { |date| { :conditions => { :published_on => date.beginning_of_month.beginning_of_day.utc..date.end_of_month.end_of_day.utc } } })
  named_scope(:unannounced, :conditions => { :announced => false })
  named_scope(:ptitle, lambda { |ptitle| { :conditions => { :parameterized_title => ptitle } } })

  before_save do |record|
    record.published_on  = Time.now.utc unless record.published_on?
    record.permalink = "/#{record.published_on_local.strftime('%Y/%m/%d')}/#{record.title.parameterize}"
    record.parameterized_title = record.title.parameterize
  end

  def category=(cat)
    write_attribute(:category, cat.downcase)
  end

  def body_html
    RedCloth.new(body).to_html
  end

  def published_on_local
    Blog.tz.utc_to_local(published_on)
  end

  def announce
    resp = RestClient.post('http://api.tr.im/v1/trim_url.json', :url => Blog.index + permalink[1..-1])
    resp = Crack::JSON.parse(resp)
    if resp['status']['code'] =~ /2\d\d/
      short_url = resp['url']
      httpauth = Twitter::HTTPAuth.new(Blog.twitter, Blog.twitter_password)
      client = Twitter::Base.new(httpauth)
      client.update("#{Blog.title}: #{title} #{short_url} #fb #in")
    else
      raise "Error with tr.im\n\n#{resp['status']['message']}"
    end
    RestClient.get('http://pingomatic.com/ping/?title=verbose+logging&blogurl=http%3A%2F%2Fblog.darkhax.com%2F&rssurl=http%3A%2F%2Fblog.darkhax.com%2Ffeed&chk_weblogscom=on&chk_blogs=on&chk_technorati=on&chk_feedburner=on&chk_syndic8=on&chk_newsgator=on&chk_myyahoo=on&chk_pubsubcom=on&chk_blogdigger=on&chk_blogrolling=on&chk_blogstreet=on&chk_moreover=on&chk_weblogalot=on&chk_icerocket=on&chk_newsisfree=on&chk_topicexchange=on&chk_google=on&chk_tailrank=on&chk_bloglines=on&chk_postrank=on&chk_skygrid=on&chk_collecta=on')
    update_attributes(:announced => true)
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
    items = key.nil? ? Cache.all : Cache.all(:conditions => { :key => key })
    items.each do |item|
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
ActiveRecord::Base.default_timezone = :utc