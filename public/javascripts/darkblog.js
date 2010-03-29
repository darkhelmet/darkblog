function ShowCommits(json) {
  $('#commits').html(Jaml.render('commit', json.commits));
}

function GithubBadge(json) {
  if (json) {
    var badge = new Object();
    badge['username'] = json.user.login;
    badge['repos'] = _.select(json.user.repositories, function(r) {
      return !r.fork && '' != r.description;
    }).sort(function() {
      return (Math.round(Math.random())-0.5);
    }).slice(0, 12);
    $('#github-badge').html(Jaml.render('github-badge', badge));
    if (!$.browser.msie) { $('a.github').tooltip(); }
  }
}

function ReaderBadge(json) {
  $('#reader-badge').html(Jaml.render('reader-badge', json));
}

$(document).ready(function() {
  $('#show-tags').click(function() {
    $('.tag1').fadeIn('slow');
    return false;
  });

  setTimeout(function() {
    $('#disqus_thread img').each(function() {
      $(this).closest('a').addClass('no-hover').attr('style', 'background-color: #7da5a5 !important');
    });
  }, 2500);

  var backgroundImagize = function(e, i) {
    $(e).css({
      'background-image': 'url(' + i.attr('src') + ')',
      'background-repeat': 'no-repeat',
      height: i.height(),
      width: i.width()
    }).addClass('img').addClass(i.attr('class'));
  };

  var backgroundizeImages = function() {
    var images = $('.entry img');
    if (_.all(images, function(i) { return i.complete; })) {
      images.each(function() {
        var div = $('<div></div>');
        backgroundImagize(div, $(this));
        $(this).replaceWith(div);
      });
    } else {
      setTimeout(backgroundizeImages, 100);
    }
  };

  var backgroundizeLinkImages = function() {
    var links = $('.entry a:has(img)');
    if (_.all(links, function(l) { return $(l).find('img')[0].complete; })) {
      links.each(function() {
        var img = $(this).find('img');
        backgroundImagize(this, $(img));
        img.remove();
      });
      $('.entry a:regex(href, png|jpe?g|gif).img').facebox();
      backgroundizeImages();
    } else {
      setTimeout(backgroundizeLinkImages, 100);
    }
  };

  backgroundizeLinkImages();

  $('a.remote-inline').live('click', function() {
    var link = $(this);
    var b = link.closest('.content').prev();
    var r = link.parent();
    link.replaceWith('Loading...');
    $.get(this.href + '?t=' + (new Date()).getTime(),
          function(data) {
            r.remove();
            b.before($(data).addClass('new-elem').css('display', 'none'));
            $('.new-elem').slideDown('slow', function() {
              $(this).removeClass('new-elem');
            });
          });
    return false;
  });

  $('.swfembed').each(function() {
    t = $(this);
    t.swfembed(t.attr('movie'), parseInt(t.attr('mwidth')), parseInt(t.attr('mheight')));
  });

  var query = $.map($('a[href$=#disqus_thread]'), function(a, index) {
    return 'url' + index + '=' + encodeURIComponent(a.href);
  }).join('&');
  $.getScript('http://disqus.com/forums/verboselogging/get_num_replies.js?' + query);

  $('#posts-container a').each(function() {
    var re = /http:\/\/twitter\.com\/\w+\/status\/(\d+)/;
    var matches = re.exec($(this).attr('href'));
    if (null != matches && 1 < matches.length) {
      var id = matches[1];
      var link = this;
      $.get('/twitter/' + id, null, function(data) {
        $(link).attr('title', data);
        if (!$.browser.msie) { $(link).tooltip(); }
      }, 'text');
    }
  });

  $.githubBadge('darkhelmet');
  $('abbr.timeago').timeago();
  $.getScript("http://www.google.com/reader/public/javascript/user/13098793136980097600/state/com.google/broadcast?n=12&callback=ReaderBadge");

  if (0 < $('#commits').length) {
    $.getScript('http://github.com/api/v2/json/commits/list/darkhelmet/darkblog/master?callback=ShowCommits');
  }
});