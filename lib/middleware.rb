ignore = %w(posts index preview edit redirections announce).map { |url| "/#{url}$" }
use Rack::BugzScout, "https://#{Blog.fogbugz_host}/scoutsubmit.asp", Blog.fogbugz_user, Blog.fogbugz_project, Blog.fogbugz_area if production?
use Rack::CanonicalHost, Blog.host if production?
use Rack::RemoveSlash
use Rack::Head
use Rack::ETag
use Rack::StaticCache, :root => 'public', :compress => true if production?
use Rack::ResponseTimeInjector, :format => '%.3f'
use Rack::InlineCompress if production?
use Rack::GoogleAnalytics, Blog.google_analytics, :ignore => ignore if production?
use Rack::Tweetboard, Blog.twitter, :ignore => ignore