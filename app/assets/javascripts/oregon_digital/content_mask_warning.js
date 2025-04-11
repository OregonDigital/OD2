// GLOBAL: Declare it globally for checking radio button
var radioButtonChecked = false;

// ON LOAD: When page refresh, it checks on the spot if radio/checkbox button being selected
$(function() {
  // LOAD: On page load filter out the JS
  $('input[name*="[mask_content][]"]').each(function() {
    var workName = $(this).attr('name');
    checkMaskContent(workName);
  });

  // CHECK: Check if any checkbox in the ':mask_content' group is checked
  $('input[name*="[mask_content][]"]').on('click', function() {
    var workName = $(this).attr('name');
    checkMaskContent(workName);
  });
});

// METHOD: Create a method to disabled field from being selected if :mask_content is not selected
function toggleDisable(disable_val) {
  $('#content_alert_default').prop('disabled', disable_val);
  $('#content_alert_custom').prop('disabled', disable_val);
  $('#content_alert_box').prop('disabled', disable_val);

  if (disable_val) {
    $('#content_alert_text').addClass('disabled-text');
  } else {
    $('#content_alert_text').removeClass('disabled-text');
  }
}

// METHOD: Check for mask content to disable or not for for :content_alert
function checkMaskContent(workName) {
  var field = 'input[name="' + workName + '"]:checked'
  if ($(field).length > 0 && !radioButtonChecked) {
    toggleDisable(false);  // Enable elements or perform actions when checked
    $('#content_alert_default').prop('checked', true);
    radioButtonChecked = true;
  } else if ($(field).length === 0) {
    toggleDisable(true);   // Disable elements or perform actions when unchecked
    $('#content_alert_default').prop('checked', false);
    $('#content_alert_custom').prop('checked', false);
    $('#content_alert_box').val('');
    radioButtonChecked = false;
  }
}
