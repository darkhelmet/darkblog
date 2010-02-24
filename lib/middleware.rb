ignore = %w(posts index preview edit redirections announce).map { |url| "/#{url}$" }

use Rack::BugzScout, "https://#{Blog.fogbugz_host}/scoutsubmit.asp", Blog.fogbugz_user, Blog.fogbugz_project, Blog.fogbugz_area if production?
use Rack::CanonicalHost, Blog.host
use Rack::RemoveSlash
use Rack::Head
use Rack::ETag
use Rack::StaticCache, :root => 'public', :compress => true if production?
use Rack::ResponseTimeInjector, :format => '%.3f'
use Rack::InlineCompress if production?

use Rack::Insert do
  %Q{<script type="text/javascript" src="http://use.typekit.com/#{Blog.typekit_id}.js"></script>
<script type="text/javascript">try{Typekit.load();}catch(e){}</script>}
end

use Rack::Insert, :ignore => ignore do
  %Q{<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker("#{Blog.google_analytics}");
pageTracker._trackPageview();
} catch(err) {}</script>}
end if production?

use Rack::Insert, :ignore => ignore do
  %Q{<script type='text/javascript' src='http://tweetboard.com/#{Blog.twitter}/tb.js'></script>}
end