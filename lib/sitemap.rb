module Sitemap
  class << self
    def by_category
      Post.published.group_by(&:category).sort do |l,r|
        l.first <=> r.first
      end.map do |cat, posts|
        [cat.capitalize, posts]
      end
    end

    def by_month
      Post.published.group_by do |post|
        post.published_on_local.strftime('%B %Y')
      end.sort do |l,r|
        r.last.first.published_on_local <=> l.last.first.published_on_local
      end
    end
  end
end