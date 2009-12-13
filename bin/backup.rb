#!/usr/bin/env ruby

require 'rubygems'
require 'aws/s3'

S3_CREDENTIALS = File.expand_path(File.join('~', '.s3', 'auth.yml'))
APP = 'darkblog'
BUCKET = 's3.blog.darkhax.com'

def bundle
  `heroku bundles --app #{APP}`.split(/\s/).first
end

def destroy
  system("heroku bundles:destroy #{bundle} --app #{APP}")
end

def create
  system('heroku bundles:capture --app #{APP}')
end

def capturing?
  !`heroku bundles --app #{APP}`.match('capturing').nil?
end

def download
  `heroku bundles:download --app #{APP}`.split(' ').last
end

def key
  Time.now.strftime('%m-%d-%Y-%H-%M.tar.gz')
end

def backup!
  destroy
  create

  print 'Waiting for capture to finish...'
  while capturing?
    print '.'
    sleep(1)
  end
  print "done!\n"

  AWS::S3::Base.establish_connection!(YAML.load_file(S3_CREDENTIALS))
  archive = download
  File.open(archive, 'rb') do |f|
    AWS::S3::S3Object.store("/backups/#{key}", f, BUCKET)
  end
  File.unlink(archive)
  print "Done!\n"
end

backup!