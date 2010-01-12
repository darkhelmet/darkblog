require File.dirname(__FILE__) + '/support_lite'
require File.dirname(__FILE__) + '/markup_plugin/form_builder/abstract_form_builder'
require File.dirname(__FILE__) + '/markup_plugin/form_builder/standard_form_builder'
Dir[File.dirname(__FILE__) + '/markup_plugin/*.rb'].each {|file| load file }

module Sinatra
  module MarkupPlugin
    def self.registered(app)
      app.set :default_builder, 'StandardFormBuilder'
      app.helpers OutputHelpers
      app.helpers TagHelpers
      app.helpers AssetTagHelpers
      app.helpers FormHelpers
      app.helpers FormatHelpers
    end
  end

  register MarkupPlugin
end