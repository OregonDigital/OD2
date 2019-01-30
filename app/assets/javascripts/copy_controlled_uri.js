function copy_uri(e) {
  field_id = e.target.id.replace("hidden_label", "id")
  val = $(e.target).val()
  document.getElementById(field_id).value = val
}

Blacklight.onLoad(function () {
  $('.controlled_field').on('keyup', copy_uri)
});