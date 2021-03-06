require 'yaml'

begin
  require 'ruby-debug'
rescue LoadError
end

desc 'Setup environment'
task :env do
  load 'darkblog.rb'
end

namespace :db do
  desc 'start postgres'
  task :start do
    exec('postgres -D $HOME/opt/homebrew/var/postgres')
  end

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
    Cache.clear
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

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
end

namespace :yard do
  desc 'Purge docs'
  task :purge do
    %x{rm -rf doc/ .yardoc}
  end
end

begin
  require 'spec/rake/spectask'
  desc 'Run tests'
  Spec::Rake::SpecTask.new('spec') do |t|
    ENV['RACK_ENV'] = 'test'
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.spec_opts = ['--colour', '--format', 'nested', '--debugger', '--backtrace']
  end
rescue LoadError
end

desc 'Local test setup'
task :local do
  ENV['RACK_ENV'] = 'test'
end

task :default => %w(local db:migrate spec)

desc 'Install gem locally'
task :gem,:name do |task, args|
  if args.name
    system("gem i #{args.name} -i vendor --ignore-dependencies")
  end
end

namespace :coffee do
  desc 'Build coffee files'
  task :build => Dir['lib/coffee/*.coffee'] do |task|
    File.open('public/javascripts/darkcoffee.js', 'wb') do |f|
      task.prerequisites.each do |path|
        IO.popen("coffee --no-wrap -p '#{path}'") do |io|
          f.write(io.read)
        end
      end
    end
  end
end

begin
  require 'aws/s3'
  require 'find'
  require 'mime/types'
  BUCKET = 'static.verboselogging.com'

  desc 'Upload images and swf to S3'
  task :upload_assets => :env do
    path = File.expand_path(File.join('~', '.s3', 'auth.yml'))
    if File.exists?(path)
      AWS::S3::Base.establish_connection!(YAML.load_file(path))
      public_dir = File.join(File.dirname(__FILE__), 'public')
      Find.find(public_dir) do |path|
        if path.match(/\.(swf|png|gif|jpg)$/)
          key = path.gsub("#{public_dir}/", '')
          print "Uploading #{path}..."
          File.open(path, 'rb') do |f|
            AWS::S3::S3Object.store(key, f, BUCKET,
                                    :content_type => MIME::Types.type_for(path).first.to_s,
                                    :access => :public_read,
                                    'Cache-control' => "public, must-revalidate, max-age=#{6.months}")
          end
          print "done\n"
        end
      end
    else
      print "No S3 auth file!\n"
    end
  end
rescue LoadError
  print "You need the aws/s3 gem to upload assets\n"
end