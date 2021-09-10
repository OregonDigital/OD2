function transitionChevron(elem) {
  elem = $(elem).find('.activity-dropdown');
  if (elem.hasClass('glyphicon-chevron-right')) {
    elem.removeClass('glyphicon-chevron-right').addClass('glyphicon-chevron-down');
  } else {
    elem.removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-right');
  }
}