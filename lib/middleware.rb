ignore = %w(posts index preview edit redirections announce).map { |url| "/#{url}$" }
use Rack::CanonicalHost, Blog.host if production?
use Rack::StaticCache, :urls => STATIC_PATHS, :root => 'public', :compress => true if production?
use Rack::RemoveSlash
use Rack::GoogleAnalytics, 'UA-2062105-4', :ignore => ignore if production?
use Rack::Tweetboard, Blog.twitter, :ignore => ignore
use Rack::InlineCompress, :ignore => ['/feed'] if production?
use Rack::ResponseTimeInjector, :format => '%.3f'
use Rack::ETag
use Rack::BugzScout, "https://#{Blog.fogbugz_host}/scoutsubmit.asp", Blog.fogbugz_user, Blog.fogbugz_project, Blog.fogbugz_area if production?