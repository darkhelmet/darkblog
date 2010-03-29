var GithubBadge, ReaderBadge, ShowCommits;
String.prototype.empty = function empty() {
  return '' === this;
};
Array.prototype.all = function all(f) {
  return -1 === this.map(f).indexOf(false);
};
ShowCommits = function ShowCommits(json) {
  return $('#commits').html(Jaml.render('commit', json.commits));
};
GithubBadge = function GithubBadge(json) {
  var badge;
  if (json) {
    badge = {
      username: json.user.login,
      repos: (json.user.repositories.filter(function(repo) {
        return !repo.fork && !repo.description.empty();
      }).sort(function() {
        return Math.round(Math.random()) - 0.5;
      })).slice(0, 12)
    };
    $('#github-badge').html(Jaml.render('github-badge', badge));
    if (!($.browser.msie)) {
      return $('a.github').tooltip();
    }
  }
};
ReaderBadge = function ReaderBadge(json) {
  return $('#reader-badge').html(Jaml.render('reader-badge', json));
};
$(document).ready(function() {
  var backgroundImagize, backgroundizeImages, backgroundizeLinkImages, query;
  $('#show-tags').click(function() {
    $('.tag1').fadeIn('slow');
    return false;
  });
  setTimeout((function() {
    return $('#disqus_thread img').each(function() {
      return $(this).closest('a').addClass('no-hover').attr('style', 'background-color: #7da5a5 !important');
    });
  }), 2500);
  backgroundImagize = function backgroundImagize(e, i) {
    return $(e).css({
      'background-image': 'url(' + i.attr('src') + ')',
      'background-repeat': 'no-repeat',
      height: i.height(),
      width: i.width()
    }).addClass('img').addClass(i.attr('class'));
  };
  backgroundizeImages = function backgroundizeImages() {
    var images;
    images = $('.entry img');
    return images.toArray().all(function(i) {
      return i.complete;
    }) ? images.each(function() {
      var div;
      div = $('<div></div>');
      backgroundImagize(div, $(this));
      return $(this).replaceWith(div);
    }) : setTimeout((function() {
      return backgroundizeImages;
    }), 100);
  };
  backgroundizeLinkImages = function backgroundizeLinkImages() {
    var links;
    links = $('.entry a:has(img)');
    if (links.toArray().all(function(l) {
      return $(l).find('img')[0].complete;
    })) {
      links.each(function() {
        var img;
        img = $(this).find('img');
        backgroundImagize(this, $(img));
        return img.remove();
      });
      $('.entry a:regex(href, png|jpe?g|gif).img').facebox();
      return backgroundizeImages();
    } else {
      return setTimeout((function() {
        return backgroundizeLinkImages;
      }), 100);
    }
  };
  backgroundizeLinkImages();
  $('a.remote-inline').live('click', (function() {
    var b, link, r;
    link = $(this);
    b = link.closest('.content').prev();
    r = link.parent();
    link.replaceWith('Loading...');
    $.get(this.href + '?t=' + (new Date()).getTime(), (function(data) {
      r.remove();
      b.before($(data).addClass('new-elem').css('display', 'none'));
      return $('.new-elem').slideDown('slow', (function() {
        return $(this).removeClass('new-elem');
      }));
    }));
    return false;
  }));
  $('.swfembed').each(function() {
    var t;
    t = $(this);
    return t.swfembed(t.attr('movie'), parseInt(t.attr('mwidth')), parseInt(t.attr('mheight')));
  });
  query = $.map($('a[href$=#disqus_thread]'), (function(a, index) {
    return 'url' + index + '=' + encodeURIComponent(a.href);
  })).join('&');
  $.getScript('http://disqus.com/forums/verboselogging/get_num_replies.js?' + query);
  $('#posts-container a').each(function() {
    var id, link, matches, re;
    re = /http:\/\/twitter\.com\/\w+\/status\/(\d+)/;
    matches = re.exec($(this).attr('href'));
    if (null !== matches && 1 < matches.length) {
      id = matches[1];
      link = this;
      return $.get('/twitter/' + id, null, (function(data) {
        $(link).attr('title', data);
        if (!($.browser.msie)) {
          return $(link).tooltip();
        }
      }), 'text');
    }
  });
  $.githubBadge('darkhelmet');
  $('abbr.timeago').timeago();
  $.getScript("http://www.google.com/reader/public/javascript/user/13098793136980097600/state/com.google/broadcast?n=12&callback=ReaderBadge");
  0 < $('#commits').length ? $.getScript('http://github.com/api/v2/json/commits/list/darkhelmet/darkblog/master?callback=ShowCommits') : null;
  return true;
});