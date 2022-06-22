function post_collection_update(event) {
  event.preventDefault();

  let collection_id = event.target.elements.member_of_collection_ids.value
  let batch_ids = []
  $(event.target.elements['batch_document_ids[]']).each(function() {
    batch_ids.push(this.value)
  });

  $.ajax({
    method: "POST",
    async: true,
    timeout: 100,
    url: event.target.action,
    data: {"collection": {"member_of_collection_ids": collection_id, "members": "add"}, "commit": "Save", "batch_document_ids": batch_ids, "id": collection_id},
    complete: function(jqXHR, status) {
      alert('Your work(s) are being added to the collection. Please give us time to process this request. You can find your collection under My Account > My Collections');
    }
  });
};
