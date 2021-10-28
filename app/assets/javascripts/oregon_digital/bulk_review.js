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
      alert('Your work(s) are being added to the collection. Please give us time to process this request');
    }
  });
};
      