$KCODE = 'u' if RUBY_VERSION.match(/1\.8/)

$: << File.expand_path(File.join('.', 'lib'))

# THIS IS BUNDLER 0.8!!!
require File.join(File.dirname(__FILE__), 'vendor/gems/environment')

# Have to require sinatra here
Bundler.require_env

require 'blog_helper'

require 'darkblog'
require 'models'
run Darkblog