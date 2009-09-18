var lightboxVars = { imageLoading: 'http://s3.blog.darkhax.com/lightbox-ico-loading.gif',
                     imageBtnClose: 'http://s3.blog.darkhax.com/lightbox-btn-close.gif',
                     imageBtnPrev: 'http://s3.blog.darkhax.com/lightbox-btn-prev.gif',
                     imageBtnNext: 'http://s3.blog.darkhax.com/lightbox-btn-next.gif',
                     imageBlank: 'http://s3.blog.darkhax.com/lightbox-blank.gif' }

$(document).ready(function() {
  $('a.remote-inline').live('click', function() {
    var link = $(this);
    link.replaceWith('Loading...');
    $.ajax({url: this.href,
            type: 'GET',
            success: function(data) {
              link.closest('.content').prev().before($(data).addClass('new-elem').css('display','none'));
              $('.new-elem').slideDown('slow', function() {
                $(this).removeClass('new-elem');
              });
            }});
    link.parent().remove();
    return false;
  });
  $('a.lightbox').lightBox(lightboxVars);
});