function copyContentWarningValue(event) {
  $(event.target).parent().find('input[type=radio]').val(event.target.value);
}