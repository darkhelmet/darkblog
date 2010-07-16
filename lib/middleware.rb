ignore = %w(posts index preview edit redirections announce).map { |url| "/#{url}$" }

use Rack::BugzScout, "https://#{Blog.fogbugz_host}/scoutsubmit.asp", Blog.fogbugz_user, Blog.fogbugz_project, Blog.fogbugz_area if production?
use Rack::CanonicalHost, Blog.host if production?
use Rack::RemoveSlash
use Rack::Head
use Rack::ETag
use Rack::StaticCache, :root => 'public', :compress => true if production?
use Rack::ResponseTimeInjector, :format => '%.3f'
use Rack::InlineCompress if production?
use Rack::Gist, :jquery => false

use Rack::Insert, :ignore => ignore do
  %Q{<script type='text/javascript' src='http://www.google-analytics.com/ga.js'></script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker('#{Blog.google_analytics}');
pageTracker._trackPageview();
} catch(err) {}</script>}
end if production?

use Rack::Insert, :ignore => ignore do
  %Q{<script type='text/javascript' src='http://tweetboard.com/#{Blog.twitter}/tb.js'></script>}
end