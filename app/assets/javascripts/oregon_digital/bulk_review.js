function updateRouteForWorkflows(button) {
  clicked_ids = []
  $('input[type=checkbox]').each(function() {
    if (this.checked == true) {
      clicked_ids.push($(`#${this.id}`).val())
    }
  });
  $('#bulk_review_button').parent().attr('action', `/bulk_review/${clicked_ids}?locale=en`)
}