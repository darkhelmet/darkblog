xml.instruct!
xml.instruct!('xml-stylesheet', :type => 'text/xsl', :href => "http://localhost:9393/sitemap.xsl")
xml.urlset('xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:schemaLocation' => 'http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9') do
  xml.url do
    xml.loc(Blog.index)
    xml.lastmod(@posts.first.updated_at)
    xml.changefreq('daily')
    xml.priority(1.0)
  end
  @posts.each do |post|
    xml.url do
      xml.loc(post_permaurl(post))
      xml.lastmod(post.updated_at)
      xml.changefreq('monthly')
      xml.priority(0.2)
    end
  end
end