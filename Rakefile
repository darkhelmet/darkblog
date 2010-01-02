require 'darkblog'
require 'yard'
require 'spec/rake/spectask'

namespace :db do
  desc 'Run database migrations'
  task :migrate do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate('db/migrate')
  end

  desc 'Reset the database'
  task :reset do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.down('db/migrate')
    ActiveRecord::Migrator.migrate('db/migrate')
  end
end

namespace :cache do
  desc 'Purge cache items'
  task :purge do
    Cache.purge(nil)
  end
end

namespace :texticle do
  desc 'Create full text search indexes'
  task :create_indexes => [:destroy_indexes] do
    Post.full_text_indexes.each { |fti| fti.create }
  end

  desc 'Destroy full text search indexes'
  task :destroy_indexes do
    Post.full_text_indexes.each { |fti| fti.destroy }
  end
end

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb', 'darkblog.rb']
end

desc 'Run tests'
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['--colour', '--format', 'nested']
end

task :default => [:spec]
