function transitionActivityChevron() {
  if ($('.activity-dropdown').hasClass('glyphicon-chevron-right')) {
    $('.activity-dropdown').removeClass('glyphicon-chevron-right');
    $('.activity-dropdown').addClass('glyphicon-chevron-down');
  } else {
    $('.activity-dropdown').removeClass('glyphicon-chevron-down');
    $('.activity-dropdown').addClass('glyphicon-chevron-right');
  }
}

function transitionSettingsChevron() {
  if ($('.activity-dropdown').hasClass('glyphicon-chevron-right')) {
    $('.activity-dropdown').removeClass('glyphicon-chevron-right');
    $('.activity-dropdown').addClass('glyphicon-chevron-down');
  } else {
    $('.activity-dropdown').removeClass('glyphicon-chevron-down');
    $('.activity-dropdown').addClass('glyphicon-chevron-right');
  }
}