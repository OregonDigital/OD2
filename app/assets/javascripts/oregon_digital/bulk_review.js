function bulkReview(event) {
  event.preventDefault();
  clicked_ids = []
  $('input[type=checkbox]').each(function() {
    if (this.checked == true) {
      clicked_ids.push($(`#${this.id}`).val())
    }
  });    
  $.ajax({
    method: "POST",
    async: true,
    timeout: 100,
    url: `/bulk_review/${clicked_ids}?locale=en`,
    complete: function(jqXHR, status) {
      alert('The selected works are currently being processed for review. Pleasse allow the system time to process these,');
    }
  });
};
      