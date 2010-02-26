module BlogHelper
  module Utilities
    def get_page(page)
      (page || 1).to_i
    end

    def enable_sharing
      @sharing = true
    end

    def sharing?
      @sharing || false
    end

    def user_agent
      env['HTTP_USER_AGENT']
    end

    def user_agent?(s)
      user_agent.try(:match, s)
    end

    def remote_hostname
      host = env['REMOTE_ADDR'].split(',').first.strip
      Socket.getaddrinfo(host, nil)[0][2]
    end

    def not_found_notification
      if named_routes.values.any? { |path| path.match(env['REQUEST_PATH']) }
        FogBugz::BugzScout.submit("https://#{Blog.fogbugz_host}/scoutsubmit.asp") do |scout|
          scout.user = Blog.fogbugz_user
          scout.project = Blog.fogbugz_project
          scout.area = Blog.fogbugz_area
          scout.title = "404 Not Found - #{env['PATH_INFO']}"
          scout.body = "Remote host: #{remote_hostname} (#{env['REMOTE_ADDR']})"
        end
      end
    rescue Exception
    end

    def announce
      RestClient.get('http://pingomatic.com/ping/?title=verbose+logging&blogurl=http%3A%2F%2Fblog.darkhax.com%2F&rssurl=http%3A%2F%2Fblog.darkhax.com%2Ffeed&chk_weblogscom=on&chk_blogs=on&chk_technorati=on&chk_feedburner=on&chk_syndic8=on&chk_newsgator=on&chk_myyahoo=on&chk_pubsubcom=on&chk_blogdigger=on&chk_blogrolling=on&chk_blogstreet=on&chk_moreover=on&chk_weblogalot=on&chk_icerocket=on&chk_newsisfree=on&chk_topicexchange=on&chk_google=on&chk_tailrank=on&chk_bloglines=on&chk_postrank=on&chk_skygrid=on&chk_collecta=on')
      RestClient.get('http://feedburner.google.com/fb/a/pingSubmit?bloglink=http://blog.darkhax.com/')
      rebuild_sidebar
    end

    def rebuild_sidebar
      Cache.put('extra_sidebar', partial(:extra_sidebar))
    end

    def individual_tweet(id)
      Cache.get("twitter:status:#{id}", 1.year) { Social.tweet(id, Blog.twitter, Blog.twitter_password) }
    end
  end
end