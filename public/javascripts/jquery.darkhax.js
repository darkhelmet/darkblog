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
    }
  });
})(jQuery);

$(document).ready(function() {
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

  setupZoom();

  $('.swfembed').each(function() {
    t = $(this);
    t.swfembed(t.attr('movie'), parseInt(t.attr('mwidth')), parseInt(t.attr('mheight')));
  });

  var query = $.map($('a[href$=#disqus_thread]'), function(a, index) {
    return 'url' + index + '=' + encodeURIComponent(a.href);
  }).join('&');
  $.getScript('http://disqus.com/forums/verboselogging/get_num_replies.js?' + query);

  $('a.github').tipsy({
    gravity: 'e',
    fade: true
  });

  $('#posts-container a').each(function() {
    var re = /http:\/\/twitter\.com\/\w+\/status\/(\d+)/;
    var matches = re.exec($(this).attr('href'));
    if (null != matches && 1 < matches.length) {
      var id = matches[1];
      var link = this;
      $.get('/twitter/' + id, null, function(data) {
        $(link).attr('title', data).tipsy({
          gravity: $.fn.tipsy.autoNS,
          fade: true
        });
      }, 'text');
    }
  });
});