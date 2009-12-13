require 'darkblog'
require 'texticle/tasks'

namespace :db do
  task :migrate do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate('db/migrate')
  end

  task :reset do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.down('db/migrate')
    ActiveRecord::Migrator.migrate('db/migrate')
  end
end

namespace :cache do
  task :purge do
    Cache.purge(nil)
  end
end

namespace :wp do
  task :migrate do
    require '../wp_ar/wp_ar.rb'
    ActiveRecord::Base.default_timezone = :local
    WpBlogPost.all(:conditions => { :post_type => 'post', :post_status => ['publish','future'] }).reverse_each do |post|
      Post.create(:title => post.post_title,
                  :published => true,
                  :published_on => (post.post_date + 1.hour).utc,
                  :category => post.term_taxonomies.select { |tt| tt.taxonomy == 'category' }.map { |t| t.term.name }.first,
                  :body => post.post_content, :tag_list => post.tags.map(&:name))
    end
  end
end

task :console do
  exec('irb -r darkblog')
end

task :environment do
end