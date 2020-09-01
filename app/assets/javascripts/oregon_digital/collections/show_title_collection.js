function toggleTitleOn(title) {
  $('.show-me' + title).toggle();
  $('#image-' + title).children('img').css({border: '5px solid black'});
}
function toggleTitleOff(title) {
  $('.show-me' + title).toggle();
  $('#image-' + title).children('img').css({border: '0px solid black'});
}