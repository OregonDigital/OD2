function post_collection_update() {
  let collection_id = $('#member_of_collection_ids')[0].value
  let batch_ids = []
  $('input[type=checkbox]').each(function() {
    if (this.checked) {
      batch_ids.push(this.id.split("_")[2])
    }
  });

  $.ajax({
    method: "POST",
    async: false,
    timeout: 100,
    url: "/dashboard/collections/" + collection_id,
    data: {"collection": {"member_of_collection_ids": collection_id, "members": "add"}, "commit": "Save", "batch_document_ids": batch_ids, "id": collection_id}
  })
    .done(function( msg ) {
    });
};
