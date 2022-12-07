function toggleFooter(parent, footer) {
  // $('(.login-footer, .modal-footer)', parent).hide();
  $(parent).find('.login-footer,.modal-footer').hide();
  $(footer).toggle();
  console.log({ parent, footer });
  console.log({ hide: $('.login-footer,.modal-footer', parent), toggle: $(footer) });

  var e = $.Event('shown.bs.modal', {});
  $('#user-login-modal').trigger(e);
}
$(document).ready(function () {
  modal_select = $("input[name=login-select]:checked")[0];
  page_select = $("input[name=login-page-select]:checked")[0];
  if (modal_select != undefined) {
    modal_select.onclick();
  }
  if (page_select != undefined) {
    page_select.onclick();
  }
});