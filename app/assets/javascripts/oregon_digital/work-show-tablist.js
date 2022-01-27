$(document).ready(function() {
  // Grab all buttons to apply on show events
  let tabslist = $('#work-show-tablist').find('[data-toggle="tab"]');

  tabslist.on('show.bs.tab', function(e) {
    // Bootstrap doesn't pass the old element because we use buttons instead of anchors
    var oldElem = $('#work-show-tablist li.active [data-toggle="tab"]' );
    // But the new element works fine
    var newElem = $(e.target);
    // old element is aria-expanded false, aria-disabled false
    // new element is the opposite
    oldElem.attr('aria-expanded', false).attr('aria-disabled', false);
    newElem.attr('aria-expanded', true).attr('aria-disabled', true);
  });
} );

