require 'term_extraction'
require 'RedCloth'

class Post < ActiveRecord::Base
  has_many :redirections, :dependent => :destroy
  has_many :keywordings, :dependent => :destroy, :include => :keyword
  has_many :keywords, :through => :keywordings, :uniq => true

  after_save { |post| post.update_keywords! }

  index do
    title
    category
    body
    cached_tag_list
  end

  validates_presence_of :title
  validates_presence_of :category

  acts_as_taggable

  default_scope(:order => 'published_on DESC', :include => :tags, :include => :keywords)
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

  def body_clean
    Hpricot(body_html).innerText
  end

  def published_on_local
    Blog.tz.utc_to_local(published_on)
  end

  def announce
    update_attributes(:announced => true)
  end

  def extract_keywords!
    # @zemanta_keywords ||= TermExtraction::Zemanta.new(:api_key => Blog.zemanta_api_key, :context => body_clean).terms
    @yahoo_keywords ||= TermExtraction::Yahoo.new(:api_key => Blog.yahoo_api_key, :context => body_clean).terms
  end

  def update_keywords(*words)
    words.each do |word|
      keywords << Keyword.find_or_create_by_name(word)
    end
  end

  def update_keywords!
    Keywording.destroy_all(:post_id => id)
    update_keywords(*extract_keywords!)
  end

  class << self
    def find_by_keywords(*args)
      find_by_sql(["SELECT p.*, pkw.relevance FROM (SELECT kw.post_id, COUNT(*) AS relevance FROM keywordings kw INNER JOIN keywords k ON kw.keyword_id = k.id WHERE k.name IN (?) GROUP BY kw.post_id HAVING COUNT(*) > 0) pkw INNER JOIN posts p ON pkw.post_id = p.id WHERE published = true ORDER BY pkw.relevance DESC", words(args.flatten)])
    end

  protected

    def words(args)
      words = case args.first
              when Post
                args.first.keywords.map(&:name)
              when Keyword
                args.map(&:name)
              else
                args
              end
    end
  end
end