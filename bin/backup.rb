#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'aws/s3'
require 'restclient'

S3_CREDENTIALS = File.expand_path(File.join('~', '.s3', 'auth.yml'))
HTTP_CREDENTIALS = File.expand_path(File.join('~', '.darkblog', 'auth.yml'))
APP = 'darkblog'
BUCKET = 's3.blog.darkhax.com'

def bundle
  `heroku bundles --app #{APP}`.split(/\s/).first
end

def capturing?
  !`heroku bundles --app #{APP}`.match('capturing').nil?
end

def capture
  system("heroku bundles:destroy #{bundle} --app #{APP}")
  system("heroku bundles:capture --app #{APP}")
  print 'Waiting for capture to finish...'
  while capturing?
    print '.'
    sleep(1)
  end
  print "done!\n"
end

def download
  `heroku bundles:download --app #{APP}`.split(' ').last
end

def key(ext)
  Time.now.strftime("%m-%d-%Y-%H-%M.#{ext}")
end

def backup_bundle!
  capture
  archive = download
  File.open(archive, 'rb') do |f|
    AWS::S3::S3Object.store("/backups/#{key('tar.gz')}", f, BUCKET)
  end
end

def backup_json!
  user, pass = YAML.load_file(HTTP_CREDENTIALS)
  json = RestClient.get("http://#{user}:#{pass}@blog.darkhax.com/dump.json").body
  AWS::S3::S3Object.store("/backups/#{key('json')}", json, BUCKET)
end

AWS::S3::Base.establish_connection!(YAML.load_file(S3_CREDENTIALS))
backup_bundle!
backup_json!
print "Done!\n"