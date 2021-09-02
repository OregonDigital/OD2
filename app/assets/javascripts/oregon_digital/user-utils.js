$(document).ready(function() {
  // Make spacebar close account information dropdown/disclosure
  $('#user-dropdown').on('keydown', function(e) {
    if(e.key == ' ') {
      e.preventDefault();
      e.stopPropagation();
      $(this).trigger('click');
    }
  });

  // Close dropdown/disclosure after leaving focus
  $('#user-dropdown').parent().on('focusout', function(event) {
    var dropdown = $('#user-dropdown');
    if (!$.contains(event.currentTarget, event.relatedTarget)) {
      if (dropdown.parent().hasClass('open')) {
        $('#user-dropdown').dropdown('toggle');
      }
    }
  });

  $('.activity-toggle').on('keydown', function(e) {
    if(e.key == ' ') {
      e.preventDefault();
      e.stopPropagation();
      $(this).trigger('click');
    }
  });

  $('.activity-toggle').parent().on('focusout', function(event) {
    var dropdown = $('#user-dropdown');
    if (!$.contains(event.currentTarget, event.relatedTarget)) {
      $('.activity-toggle').trigger('click');
    }
  });
});