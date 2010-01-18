(function($) {
  $.fn.extend({
    swfembed: function(movie, width, height) {
      this.each(function() {
        scale = 600 / width;
        w = '600px';
        h = (height * scale) + 'px';
        swfobject.embedSWF(movie, this.id, w, h, '9.0.124', '/swf/expressInstall.swf',
                           null, { wmode: 'opaque', allowFullscreen: true });
      });
    },
    tooltip: function(options) {
      settings = $.extend({
        xOffset: -40,
        yOffset: 25
      }, options);

      this.each(function() {
        $(this).hover(function(e) {
          this.t = this.title;
          this.title = '';
          $('body').append($('<p>', {
            id: 'tooltip',
            text: this.t,
            css: {
              position: 'absolute'
            }
          }));
          $('#tooltip').css({
            top: (e.pageY + settings.yOffset) + 'px',
            left: (e.pageX + settings.xOffset) + 'px'
          }).fadeIn('fast');
        }, function() {
          this.title = this.t;
          $('#tooltip').remove();
        }).mousemove(function(e) {
          $('#tooltip').css({
            top: (e.pageY + settings.yOffset) + 'px',
            left: (e.pageX + settings.xOffset) + 'px'
          });
        })
      });
    }
  });
})(jQuery);

$(document).ready(function() {
  setupZoom();

  $('a.remote-inline').live('click', function() {
    var link = $(this);
    var b = link.closest('.content').prev();
    var r = link.parent();
    link.replaceWith('Loading...');
    $.ajax({url: this.href,
            type: 'GET',
            success: function(data) {
              r.remove();
              b.before($(data).addClass('new-elem').css('display','none'));
              $('.new-elem').slideDown('slow', function() {
                $(this).removeClass('new-elem');
              });
            }});
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

  if (!$.browser.msie) {
    $('a.github').tooltip();
  }

  $('.content a:not(:has(img))').addClass('hover');

  $('#show-tags').click(function() {
    $('.tag1').fadeIn('slow');
    return false;
  });

  $('#posts-container a').each(function() {
    var re = /http:\/\/twitter\.com\/\w+\/status\/(\d+)/;
    var matches = re.exec($(this).attr('href'));
    if (null != matches && 1 < matches.length) {
      var id = matches[1];
      var link = this;
      $.get('/twitter/' + id, null, function(data) {
        $(link).attr('title', data);
        if (!$.browser.msie) {
          $(link).tooltip();
        }
      }, 'text');
    }
  });
});