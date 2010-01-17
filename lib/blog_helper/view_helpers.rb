module BlogHelper
  # View related helpers
  module ViewHelpers
    def minimal_sidebar(on = nil)
      if on.nil?
        @minimal_sidebar || false
      else
        @minimal_sidebar = on
      end
    end

    def cached_partial(key, time = 1.hour)
      Cache.get("#{key}_partial", time) do
        partial(key)
      end
    end

    # Turns a Delicious bookmark into a link for insertion into the page
    #
    # @see http://github.com/weppos/www-delicious www-delicious gem
    # @param [WWW::Delicious::Post] b A bookmark/post from the www-delicious gem
    # @return [String] HTML link to the bookmark
    def delicious(b)
      link_to(h(b.description), b.href)
    end

    # Get the link to the author's Delicious profile and to add to your network
    #
    # @return [String] The HTML insertion-ready string with the relevant links
    def delicious_link
      profile_link = link_to(Blog.delicious_user, "http://delicious.com/#{Blog.delicious_user}")
      add_link = link_to('Add me to your network', "http://delicious.com/network?add=#{Blog.delicious_user}")
      "I'm #{profile_link} on Delicious.<br />#{add_link}"
    end

    # Turns a shared RSS item into a link for insertion into the page
    #
    # @see http://github.com/pauldix/feedzirra feedzirra gem
    # @param [Object] item An RSS item from the Feedzirra gem
    # @return [String] HTML link to the shared item
    def reader(item)
      link_to(h(item.title), item.url)
    end

    # Turns a Github repo from the Github API into a link to it
    #
    # @param [Hashie::Mash] r A repository
    # @return [String] HTML link to the Github repo
    def repo(r)
      link_to(h(r.name), r.url, :title => h(r.description), :class => 'github')
    end

    # Get the author's Github profile link
    #
    # @return [String] The HTML insertion-ready string with the link to the Github profile
    def github_link
      link_to('Fork me on Github, and see the rest of my code', "https://github.com/#{Blog.github}")
    end

    # Setup or get the disqus part to include after a post
    #
    # @overload disqus_part(nil)
    #   Retrieve the Disqus partial to use
    #   @return [Symbol] :disqus_index unless it has been previously set
    # @overload disqus_part(part)
    #   Set the disqus_part to use
    #   @param [String] part The part to use, 'disqus_single' or 'disqus_index'
    def disqus_part(part = nil)
      if part.nil?
        (@disqus_part || 'disqus_index').intern
      else
        @disqus_part = part
      end
    end

    # Setup or get the post to use for keywords
    #
    # @overload keywords_post(nil)
    #   Get the post to use for keywords
    #   @return [Post] The post to use for keywords
    # @overload keywords_post(post)
    #   Set the keywords post
    #   @param [Post] post The post to use for keywords
    def keywords_post(post = nil)
      if post.nil?
        @keywords_post
      else
        @keywords_post = post
      end
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
    # @return [String] The url to the Gravatar png image
    def gravatar_url(email)
      "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}.jpg?s=120"
    end

    # Generate a link to a tag
    #
    # @param [Tag,String] tag The tag to create a link to
    # @param [String] css The CSS class (foo)
    # @return [String] A partial that can be fed to HAML using {#partial}
    def tag_link(tag, css = '')
      tag = tag.to_s
      link_to(h(tag), "/tag/#{tag.url_encode}", :rel => 'tag', :class => css)
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
      Blog.index + post.permalink[1..-1]
    end

    def category_link(cat)
      link_to(h(cat.capitalize), "/category/#{cat.url_encode}")
    end

    def archive_link(date)
      link_to(date.strftime('%B %Y'), "/#{date.strftime('%Y/%m')}")
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
      link_to(image_tag("/images/icons/#{k}.png", :class => 'where', :alt => item.title), item.link, :title => item.title)
    end
  end
end