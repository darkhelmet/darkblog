$.fn.setupRemoteInline = function() {
    return this.each(function() {
            $(this).click(function() {
                    var link = $(this);
                    link.unbind('click');
                    link.html('Loading...');
                    $.ajax({
                        url:this.href,
                        type:'GET',
                        success:function(data) {
                                d = $(data).addClass('new-elem').css('display','none');
                                $(link.closest('.content').prev()).before(d);
                                $('.new-elem').slideDown('slow', function() {
                                        $(this).removeClass('new-elem');
                                    });
                                link.parent().remove();
                                $('a.remote-inline').setupRemoteInline();
                            }});
                    return false;
                });
        });
};

var lightboxVars = { imageLoading: 'http://s3.blog.darkhax.com/lightbox-ico-loading.gif',
                     imageBtnClose: 'http://s3.blog.darkhax.com/lightbox-btn-close.gif',
                     imageBtnPrev: 'http://s3.blog.darkhax.com/lightbox-btn-prev.gif',
                     imageBtnNext: 'http://s3.blog.darkhax.com/lightbox-btn-next.gif',
                     imageBlank: 'http://s3.blog.darkhax.com/lightbox-blank.gif' }

$(document).ready(function() {
        $('a.remote-inline').setupRemoteInline();
        $('a.lightbox').lightBox(lightboxVars);
    });
