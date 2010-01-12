require File.dirname(__FILE__) + '/support_lite'
Dir[File.dirname(__FILE__) + '/render_plugin/**/*.rb'].each {|file| load file }

module Sinatra
  module RenderPlugin
    def self.registered(app)
      app.helpers RenderHelpers
    end
  end

  register RenderPlugin
end