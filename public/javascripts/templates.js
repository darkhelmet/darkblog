Jaml.register('repo', function(repo) {
  li(a({ title: repo.description, cls: 'github', href: repo.url }, repo.name));
});

Jaml.register('github-badge', function(badge) {
  div({ cls: 'github-badge' },
    h1({ cls: 'center' }, "What I'm Hacking"),
    ul(
      Jaml.render('repo', badge.repos),
      li(a({ href: 'http://github.com/' + badge.username }, 'Fork me on Github, and see the rest of my code'))
    )
  );
});

Jaml.register('feed-item', function(item) {
  li(a({ title: item.title, href: item.alternate.href }, item.title));
});

Jaml.register('reader-badge', function(badge) {
  div({ cls: 'reader-badge' },
    h1({ cls: 'center' }, "What I'm Reading"),
    ul(
      Jaml.render('feed-item', badge.items),
      li(a({ href: 'http://www.google.com/reader/shared/' + badge.id }, 'View all my shared items on Google Reader'))
    )
  );
});

Jaml.register('commit', function(commit) {
  div(a({ href: commit.url }, commit.id), pre(commit.message));
});