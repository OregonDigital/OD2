$(document).ready(function() {
  // Make spacebar close account information dropdown/disclosure
  $('#user-dropdown').on('keydown', function(e) {
    if(e.key == ' ') {
      e.preventDefault();
      e.stopPropagation();
      $(this).trigger('click');
    }
  });
});