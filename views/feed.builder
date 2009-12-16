xml.instruct!
xml.rss(:version => "2.0") do
  xml.channel do
    xml.title(Blog.title)
    xml.link(Blog.index)
    xml.description(Blog.tagline)
    xml.language('en-us')
    xml.atom10(:link, "xmlns:atom10" => 'http://www.w3.org/2005/Atom', :rel => 'self', :type => 'application/rss+xml', :href => "#{Blog.index}feed")
    xml.managingEditor("#{Blog.email} (#{Blog.author})")
    xml.webMaster("#{Blog.email} (#{Blog.author})")
    xml.lastBuildDate(@posts.first.published_on.strftime('%a, %d %b %Y %H:%M:%S %z'))
    @posts.each do |post|
      xml.item do
        xml.title(post.title)
        xml.category(post.category.capitalize)
        xml.pubDate(post.published_on.strftime('%a, %d %b %Y %H:%M:%S %z'))
        xml.link(post_permaurl(post))
        xml.guid(post_permaurl(post))
        xml.author(Blog.author)
        xml.description do
          xml.cdata!(post.body_html)
        end
      end
    end
  end
end