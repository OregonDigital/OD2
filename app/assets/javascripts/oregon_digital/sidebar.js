function transitionChevron(elem) {
  elem = $(elem).find('.activity-dropdown');
  if (elem.hasClass('fa-chevron-right')) {
    elem.removeClass('fa-chevron-right').addClass('fa-chevron-down');
  } else {
    elem.removeClass('fa-chevron-down').addClass('fa-chevron-right');
  }
}