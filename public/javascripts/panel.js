$(document).ready(function() {
  $('#open').click(function(){
    $('div#panel').slideDown('slow');
    return false;
  });

  $('#close').click(function(){
    $('div#panel').slideUp('slow');
    return false;
  });

  $('#toggle a').click(function () {
    $('#toggle a').toggle();
    return false;
  });
});