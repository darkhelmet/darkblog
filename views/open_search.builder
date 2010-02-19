xml.instruct!
xml.OpenSearchDescription(:xmlns => 'http://a9.com/-/spec/opensearch/1.1/', 'xmlns:moz' => 'http://www.mozilla.org/2006/browser/search/') do
  xml.ShortName(Blog.title)
  xml.Description(Blog.tagline)
  xml.Contact(Blog.email)
  xml.Image(gravatar_url(Blog.email, 16), :height => 16, :width => 16, :type => 'image/png')
  xml.Url(:type => 'text/html', :method => 'get', :template => "#{Blog.index}search?s={searchTerms}")
  xml.moz(:SearchForm, Blog.index)
end
