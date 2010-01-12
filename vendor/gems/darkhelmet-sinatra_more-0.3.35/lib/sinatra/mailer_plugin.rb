require 'tilt'
require File.dirname(__FILE__) + '/support_lite'
require 'pony'
Dir[File.dirname(__FILE__) + '/mailer_plugin/**/*.rb'].each { |file| load file }

module Sinatra
  module MailerPlugin
    def self.registered(app)
      MailerBase::views_path = app.views
    end
  end

  register MailerPlugin
end