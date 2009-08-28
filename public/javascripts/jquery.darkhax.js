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
                                var e = $(data).find('#posts-container').children();
                                var existing = link.closest('.content').prev();
                                var sidebar = $(e[0]);
                                sidebar.hide();
                                sidebar.addClass('new-elem');
                                $(existing).before(sidebar);
                                var con = $(e[1]);
                                con.addClass('new-elem');
                                // clean out disqus
                                con.find('.inline-comment-container').remove();
                                // need to do this to make chrome happy...weird
                                con.find('script').empty().remove();
                                // clean out sociable
                                con.find('.sociable').remove();
                                con.hide();
                                $(existing).before(con);
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
