ignore = %w(posts index preview edit redirections announce).map { |url| "/#{url}$" }

use Rack::BugzScout, "https://#{Blog.fogbugz_host}/scoutsubmit.asp", Blog.fogbugz_user, Blog.fogbugz_project, Blog.fogbugz_area if production?
use Rack::CanonicalHost, Blog.host if production?
use Rack::RemoveSlash
use Rack::Head
use Rack::ETag
use Rack::StaticCache, :root => 'public', :compress => true if production?
use Rack::ResponseTimeInjector, :format => '%.3f'
use Rack::Gist, :jquery => false, :cache => Cache
use Rack::InlineCompress if production?

use Rack::Insert, :ignore => ignore do
  %Q{<script type='text/javascript' src='http://www.google-analytics.com/ga.js'></script>
<script type="text/javascript">
try {
var pageTracker = _gat._getTracker('#{Blog.google_analytics}');
pageTracker._trackPageview();
} catch(err) {}</script>}
end if production?

use Rack::Insert, :ignore => ignore do
  %Q{<link rel='stylesheet' type='text/css' media='screen' charset='utf-8' href='http://assets.skribit.com/stylesheets/SkribitSuggest.css' />
<style type="text/css" media="print" charset="utf-8">a#sk_tab{display:none !important;}</style>
<script src="http://assets.skribit.com/javascripts/SkribitSuggest.js" type="text/javascript"></script>
<script type="text/javascript" charset="utf-8">
    var skribit_settings = {};
    skribit_settings.placement = "right";
    skribit_settings.color = "#333333";
    skribit_settings.text_color = "white";
    skribit_settings.distance_vert = "32%";
    skribit_settings.distance_horiz = "";
    SkribitSuggest.suggest('http://skribit.com/lightbox/verbose-logging', skribit_settings);
</script>}
end if production?