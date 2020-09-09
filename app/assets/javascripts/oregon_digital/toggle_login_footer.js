function toggleFooter (footer) {
  if ($('#login-modal-footer-OSU-footer').is(':visible')) {
    $('#login-modal-footer-OSU-footer').toggle();
  } else if ($('#login-modal-footer-UO-footer').is(':visible')){
    $('#login-modal-footer-UO-footer').toggle();
  } else if ($('#login-modal-footer-local-footer').is(':visible')){
    $('#login-modal-footer-local-footer').toggle();
  }
  $('#login-modal-footer-' + footer).toggle();
}