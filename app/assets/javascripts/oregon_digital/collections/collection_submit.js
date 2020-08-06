function post_collection_update(event) {
  event.preventDefault();

  $.ajax({
    method: "POST",
    async: true,
    timeout: 100,
    url: "/dashboard/collections/" + collection_id,
    data: {"collection": {"member_of_collection_ids": collection_id, "members": "add"}, "commit": "Save", "batch_document_ids": batch_ids, "id": collection_id},
    complete: function(jqXHR, status) {
      alert('Your work(s) are being added to the collection. Please give us time to process this request');
    }
  });
};
