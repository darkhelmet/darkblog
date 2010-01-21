#!/usr/bin/env ruby

require 'rubygems'
require 'active_support'
require 'restclient'
require 'ruby-debug'
require 'pp'
require 'crack'
require 'aws/s3'
require 'choice'
require 'image_science'

Choice.options do
  option :user do
    short '-u'
    long '--user USER'
    desc 'The user to post as'
    default 'darkhelmet'
  end

  option :password do
    short '-p'
    long '--password PASSWORD'
    desc 'The password to use'
  end

  option :host do
    short '-H'
    long '--host HOST'
    desc 'The host to use'
    default 'blog.darkhax.com'
  end

  option :path do
    short '-P'
    long '--path PATH'
    desc 'The path to use'
    default 'posts'
  end

  option :bucket do
    short '-b'
    long '--bucket BUCKET'
    desc 'The S3 bucket for uploads'
    default 's3.blog.darkhax.com'
  end
end

class Poster
  def self.post(&blk)
    p 'No password' and return if Choice.choices[:password].blank?
    post = Poster.new
    post.instance_eval(&blk)
    pp Crack::XML.parse(post.save!)
  end

  def values
    @values ||= {}
  end

  %w(id title published_on category body tag_list published).each do |prop|
    define_method(prop) do
      values[prop]
    end

    define_method(prop) do |val|
      values[prop] = val
    end
  end

  def save!
    values.has_key?('id') ? update! : create!
  end

private

  def url
    "http://#{Choice.choices[:user]}:#{Choice.choices[:password]}@#{Choice.choices[:host]}/#{Choice.choices[:path]}"
  end

  def create!
    RestClient.post(url, :post => values)
  end

  def update!
    RestClient.put(url, :post => values)
  end
end

class Uploader
  def self.upload(&blk)
    uploader = Uploader.new
    uploader.instance_eval(&blk)
    print uploader.up!
  end

  def file(f = nil)
    return @file if f.nil?
    @file = f
  end

  def up!
    AWS::S3::Base.establish_connection!(YAML.load_file(File.expand_path(File.join('~', '.s3', 'auth.yml'))))
    pp upload(file)
    content_type = `file -Ib '#{file}'`.gsub(/\n/,'')
    if content_type =~ /image/
      name = file.split('/').last
      ext = File.extname(file)
      basename = File.basename(file, ext)
      ImageScience.with_image(file) do |img|
        img.thumbnail(100) do |thumb|
          path = "#{basename}_thumb#{ext}"
          thumb.save(path)
          pp upload(path)
        end

        img.thumbnail(600) do |med|
          path = "#{basename}_medium#{ext}"
          med.save(path)
          pp upload(path)
        end
      end
    end
  end

  def upload(path)
    AWS::S3::S3Object.store("/uploads/#{Date.today.strftime('%Y/%m')}/#{path}",
                            File.new(path),
                            Choice.choices[:bucket],
                            :content_type => `file -Ib '#{path}'`.gsub(/\n/,''),
                            :access => :public_read)
  end
end

if $0 == __FILE__
  if 0 < ARGV.size
    ARGV.each do |f|
      Uploader.upload do
        file f
      end
    end
  end
end