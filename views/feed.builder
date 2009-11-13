xml.instruct!
xml.rss(:version => "2.0") do
  xml.channel do
    xml.title(Blog.title)
    # hack
    xml.target! << "    <link>#{Blog.index}</link>\n"
    xml.description(Blog.tagline)
    xml.language('en-us')
    xml.managingEditor(Blog.email)
    xml.webMaster(Blog.email)
    xml.lastBuildDate(@posts.first.published_on)
    @posts.each do |post|
      xml.item do
        xml.title(post.title)
        xml.category(post.category.capitalize)
        xml.pubDate(post.published_on)
        xml.link(post_permaurl(post))
        xml.guid(post_permaurl(post))
        xml.author(Blog.email)
        xml.description do
          xml.cdata!(post.body_html)
        end
      end
    end
  end
end