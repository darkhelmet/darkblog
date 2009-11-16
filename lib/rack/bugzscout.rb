require 'rubygems'
require 'bugzscout' 
require 'erb'
 
module Rack
  # Catches all exceptions raised, and submits them to FogBugz via BugzScout.  
 
  class BugzScout
    attr_reader :fogbugz_url, :fogbugz_user, :fogbugz_project, :fogbugz_area
 
    def initialize(app,fogbugz_url,fogbugz_user,fogbugz_project='inbox',fogbugz_area='undecided')
      @app = app
      @fogbugz_url = fogbugz_url
      @fogbugz_user = fogbugz_user
      @fogbugz_project = fogbugz_project
      @fogbugz_area = fogbugz_area
      
      @template = ERB.new(TEMPLATE)
    end
 
    def call(env)
      status, headers, body =
        begin
          @app.call(env)
        rescue => boom
          send_notification boom, env
          raise
        end
      send_notification env['rack.exception'], env if env['rack.exception']
      [status, headers, body]
    end
  
  private

    def generate_report(exception, env)
      FogBugz::BugzScout.submit(@fogbugz_url) do |scout|
        scout.user = @fogbugz_user
        scout.project = @fogbugz_project
        scout.area = @fogbugz_area
        scout.title = exception.to_s
        scout.body = @template.result(binding)
      end
    end  
  
    def send_notification(exception, env)
      # wrapping this so we can avoid sending these up the chain
      # not entirely sure that this is the right thing to do...
      begin
        if %w(staging production).include?(ENV['RACK_ENV'])
          generate_report(exception, env)
          env['bugzscout.submitted'] = true
        end
      rescue => error
        # maybe we ought to log something here if things don't work out?
      end
    end
    
    def extract_body(env)
      if io = env['rack.input']
        io.rewind if io.respond_to?(:rewind)
        io.read
      end
    end
    
    TEMPLATE = (<<-'REPORT').gsub(/^ {4}/, '')
    A <%= exception.class.to_s %> occured: <%= exception.to_s %>
    <% if body = extract_body(env) %>
 
    ====================
    Request Body:
    ====================
    
    <%= body.gsub(/^/, '  ') %>
    <% end %>
 
    ====================
    Rack Environment:
    ====================
 
      PID:                     <%= $$ %>
      PWD:                     <%= Dir.getwd %>
 
      <%= env.to_a.
        sort{|a,b| a.first <=> b.first}.
        map{ |k,v| "%-25s%p" % [k+':', v] }.
        join("\n  ") %>
 
    <% if exception.respond_to?(:backtrace) %>
    ====================
    Backtrace:
    ====================
 
      <%= exception.backtrace.join("\n  ") %>
    <% end %>
    REPORT
    
  end
end