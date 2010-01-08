require 'yard'
require 'spec/rake/spectask'

def runcoderun?
  ENV['RUN_CODE_RUN']
end

desc 'Setup environment'
task :env do
  require 'darkblog'
end

namespace :db do
  desc 'Run database migrations'
  task :migrate => %w(env) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate('db/migrate')
  end

  desc 'Reset the database'
  task :reset => %w(env) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.down('db/migrate')
    ActiveRecord::Migrator.migrate('db/migrate')
  end

  namespace :schema do
    desc 'Dump the schema'
    task :dump => %w(env) do
      File.open('db/schema.rb', 'w') do |f|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, f)
      end
    end
  end
end

namespace :cache do
  desc 'Purge cache items'
  task :purge => %w(env) do
    Cache.purge(nil)
  end
end

namespace :texticle do
  desc 'Create full text search indexes'
  task :create_indexes => %w(destroy_indexes) do
    Post.full_text_indexes.each { |fti| fti.create }
  end

  desc 'Destroy full text search indexes'
  task :destroy_indexes => %w(env) do
    Post.full_text_indexes.each { |fti| fti.destroy }
  end
end

YARD::Rake::YardocTask.new

namespace :yard do
  desc 'Purge docs'
  task :purge do
    %x{rm -rf doc/ .yardoc}
  end
end

desc 'Run tests'
Spec::Rake::SpecTask.new('spec') do |t|
  ENV['RACK_ENV'] = 'test'
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['--colour', '--format', 'nested', '--debugger', '--backtrace']
end

desc 'Setup task for runcoderun'
task :runcoderun do
  db = 'darkhelmet_darkblog_test'
  user = 'build'
  %w(drop create).each { |action| %x(#{action}db -U #{user} #{db}) }
end

desc 'Local test setup'
task :local do
  ENV['RACK_ENV'] = 'test'
end

if runcoderun?
  ENV['RACK_ENV'] = 'test'
  task :default => %w(env runcoderun db:migrate spec)
else
  task :default => %w(local db:migrate spec)
end