function toggleFooter (footer) {
  $('#login-modal-footer-OSU-footer').hide();
  $('#login-modal-footer-UO-footer').hide();
  $('#login-modal-footer-local-footer').hide();
  $('#login-modal-footer-' + footer).toggle();

  var e = $.Event('shown.bs.modal', {});
  $('#user-login-modal').trigger(e); 
}