function post_collection_update(event) {
  event.preventDefault();
  console.log(event);
  console.log(event.target.elements.member_of_collection_ids.value);

  let collection_id = event.target.elements.member_of_collection_ids.value
  // let batch_ids = []
  // $('input[type=checkbox]').each(function() {
  //   if (this.checked) {
  //     batch_ids.push(this.id.split("_")[2])
  //   }
  // });

  $.ajax({
    method: "POST",
    async: true,
    timeout: 100,
    url: event.target.action,
    data: {"collection": {"member_of_collection_ids": collection_id, "members": "add"}, "commit": "Save", "batch_document_ids": batch_ids, "id": collection_id},
    complete: function(jqXHR, status) {
      alert('Your work(s) are being added to the collection. Please give us time to process this request');
    }
  });
};
