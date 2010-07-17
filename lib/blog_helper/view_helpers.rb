module BlogHelper
  # View related helpers
  module ViewHelpers
    def content_tag(tag, *args)
      content = block_given? ? yield : args.shift
      options = args.shift || { }
      builder do |xml|
        if options.delete(:no_escape)
          xml.tag!(tag, options) { |tag| tag << content }
        else
          xml.tag!(tag, content, options)
        end
      end
    end

    def tag(tag, options = { })
      content_tag(tag, '', options)
    end

    def link_to(text, href, options = { })
      content_tag(:a, text, options.merge(:href => href))
    end

    def meta_tag(content, options = { })
      tag(:meta, options.merge(:content => content))
    end

    def javascript_include_tag(javascript, defer = false)
      javascript = javascript.to_s
      unless javascript.match(/^(\/|http)/)
        javascript = "/javascripts/#{javascript}.js"
      end
      options = {
        :src => javascript,
        :type => 'text/javascript'
      }
      if defer
        options[:defer] = 'defer'
        options[:async] = 'async'
      end
      tag(:script, options)
    end

    def javascript_include_tags(*scripts)
      scripts.map do |script|
        javascript_include_tag(script)
      end.join("\n")
    end

    def stylesheet_link_tags(*sheets)
      sheets.map do |sheet|
        stylesheet_link_tag(sheet)
      end.join("\n")
    end

    def stylesheet_link_tag(stylesheet, media = 'screen')
      stylesheet = stylesheet.to_s
      unless stylesheet.match(/^(\/|http)/)
        stylesheet = "/stylesheets/#{stylesheet}.css"
      end
      tag(:link, :href => stylesheet, :type => 'text/css', :rel => 'stylesheet', :media => media)
    end

    def image_tag(image, options = { })
      unless image.match(/^(\/|http)/)
        image = "/images/#{image}"
      end
      tag(:img, options.merge(:src => image.to_s))
    end

    def asset_url(path, host = Blog.asset_host)
      development? ? path : "http://#{host}#{path}"
    end

    def enable_minimal_sidebar
      @minimal_sidebar = true
    end

    def minimal_sidebar?
      @minimal_sidebar || false
    end

    def preview_posts?
      @preview_posts.nil? ? true : @preview_posts
    end

    def disable_post_preview
      @preview_posts = false
    end

    def canonical(can = nil)
      can.nil? ? @canonical : @canonical = can
    end

    def cached_partial(key)
      Cache.fetch("#{key}_partial") { partial(key) }
    end

    def disqus_single
      @disqus_part = :disqus_single
    end

    def disqus_part
      @disqus_part || :disqus_index
    end

    def keywords_post(post = nil)
      post.nil? ? @keywords_post : @keywords_post = post
    end

    def keywords
      @keywords_post.try(:keywords) || []
    end

    def description(desc = nil, page = 1)
      if desc.nil?
        @description || Blog.tagline
      else
        @description = desc + if 1 < page
          ", page #{page}"
        else
          ''
        end
      end
    end

    def build_can(suffix, page = '1')
      page = page.to_i
      page_suffix = if 1 < page
        "#{suffix.empty? ? '' : '/' }page/#{page}"
      else
        ''
      end
      "#{Blog.index}#{suffix}#{page_suffix}"
    end

    # Get the FeedBurner URL for the blog
    #
    # @return [String] The URL to the FeedBurner feed
    def fb_url
      "http://feeds.feedburner.com/#{Blog.feedburner}"
    end

    # Get a Gravatar URL for an email
    #
    # @param [String] email The email to use
    # @param [Integer] size The size of the image
    # @return [String] The url to the Gravatar png image
    def gravatar_url(email, size = 140)
      "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}.png?s=#{size}"
    end

    # Get the Gravatar HTML for the value of Blog.email
    #
    # @param [Integer] size The size of the image
    # @return [String] The HTML for the document
    def gravatar_html(size = 140)
      style = {
        :height => "#{size}px",
        :width => "#{size}px",
        :background_image => "url(#{gravatar_url(Blog.email, size)})"
      }.to_a.map do |key,value|
        "#{key.to_s.gsub('_', '-')}:#{value}"
      end.join(';')
      tag(:div, :class => 'gravatar', :style => style)
    end

    # Generate a link to a tag
    #
    # @param [Tag,String] tag The tag to create a link to
    # @param [String] css The CSS class (foo)
    # @return [String] A partial that can be fed to HAML using {#partial}
    def tag_link(tag, css = '')
      tag = tag.to_s
      link_to(tag, "/tag/#{tag.url_encode}", :rel => 'tag', :class => css)
    end

    # Creates the HTML links for all the tags in a post
    #
    # @param [Post] post The post to use
    # @return [String] HTML ready to be inserted into the page
    def tag_links(post)
      post.tag_list.map { |tag| tag_link(tag) }.join("\n")
    end

    # Creates the CSS class for a post
    #
    # @param [Post] post The post to use
    # @return [String] The CSS class to be used
    def post_class(post)
      (post.tag_list.map { |tag| "tag-#{h(tag)}" } | ['post', "post-#{post.id}", "category-#{h(post.category)}"]).join(' ')
    end

    # Get the absolute permalink to a post
    #
    # @param [Post] post The post to create the link to
    # @return [String] The full URL including protocol and host
    def post_permaurl(post)
      "#{Blog.index}#{post.permalink[1..-1]}"
    end

    def category_link(cat)
      link_to(cat.capitalize, "/category/#{cat.url_encode}")
    end

    def archive_link(date)
      count = Post.published.monthly(date).count
      link_to(date.strftime("%B %Y (#{count})"), "/#{date.strftime('%Y/%m')}")
    end

    def monthly_archive_links
      newest = Post.published.first
      return Array.new if newest.nil?
      newest = newest.published_on_local
      oldest = Post.published.last.published_on_local
      (ArchiveDate.new(oldest.year, oldest.month, 1)..ArchiveDate.new(newest.year, newest.month, 1)).map do |date|
        archive_link(date)
      end
    end

    def title(t = nil, page = 1)
      if t.nil?
        @title || Blog.title
      else
        @title = "#{t} | #{Blog.title}"
        if 1 < page
          @title += " | Page #{page}"
        end
      end
    end

    def where_link(k)
      item = Social.where[k]
      link_to(image_tag(asset_url("/images/icons/#{k}.png"),
                        :alt => item.title),
              item.link,
              :title => item.title,
              :class => 'where',
              :no_escape => true)
    end

    def delete_link(url)
      link_to('delete', "javascript:if (confirm('Really delete this?')) {
  $.ajax({
    url: '#{url}',
    dataType: 'script',
    type: 'DELETE'
  });
}")
    end

    # Stolen from rails
    def truncate(text, *args)
      options = args.extract_options!
      unless args.empty?
        ActiveSupport::Deprecation.warn('truncate takes an option hash instead of separate ' +
          'length and omission arguments', caller)

        options[:length] = args[0] || 30
        options[:omission] = args[1] || "..."
      end
      options.reverse_merge!(:length => 30, :omission => '...')

      if text
        l = options[:length] - options[:omission].mb_chars.length
        chars = text.mb_chars
        stop = options[:separator] ? (chars.rindex(options[:separator].mb_chars, l) || l) : l
        (chars.length > options[:length] ? chars[0...stop] + options[:omission] : text).to_s
      end
    end

    def post_title_link(post)
      content_tag(:h1, :class => 'post-title', :no_escape => true) { post_link(post) }
    end

    def post_link(post)
      link_to(post.title, post.permalink, :rel => 'bookmark', :title => "Permanent Link to #{post.title}")
    end
  end
end