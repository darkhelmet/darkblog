(function($) {
  $.fn.extend({
    swfembed: function(movie, width, height) {
      this.each(function() {
        scale = 600 / width;
        w = '600px';
        h = (height * scale) + 'px';
        swfobject.embedSWF(movie, this.id, w, h, '9.0.124', '/swf/expressInstall.swf', null, { wmode: 'opaque', allowFullscreen: true });
      });
    }
  });
})(jQuery);

var lightboxVars = { imageLoading: 'http://s3.blog.darkhax.com/lightbox-ico-loading.gif',
                     imageBtnClose: 'http://s3.blog.darkhax.com/lightbox-btn-close.gif',
                     imageBtnPrev: 'http://s3.blog.darkhax.com/lightbox-btn-prev.gif',
                     imageBtnNext: 'http://s3.blog.darkhax.com/lightbox-btn-next.gif',
                     imageBlank: 'http://s3.blog.darkhax.com/lightbox-blank.gif' };

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

  $('a.lightbox').lightBox(lightboxVars);

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
      }, 'text');
    }
  });
});