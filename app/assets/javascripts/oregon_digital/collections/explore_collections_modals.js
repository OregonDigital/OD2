$(document).ready(function() {
  titles = [];
  descriptions = [];
  // Show loading gif and hide the form when edit collection modal closes
  $('#collection-edit-container').on('hidden.bs.modal', function(e) {
    $('.loading', this).show();
    $('.form', this).hide();
  });

  // Javascript to enable link to tab
  var hash = document.location.hash;
  if (hash) {
    $('.nav-pills a[href=\\'+hash+']').tab('show');
  }

  // Change hash for page-reload
  $('a[data-toggle="pill"]').on('shown.bs.tab', function (e) {
    window.location.hash = e.target.hash;
  });

  $('.remove_from_collection').on('submit', function(e) {
    $('input[type=submit]').prop('disabled', true);
  });
});

function open_edit_my_collection_modal(collection_id) {
  form = $('#collection-edit-container .modal-content .modal-body form');
  form.attr('action', "/dashboard/collections/" + collection_id);
  title_input = form.find('input[name="collection[title][]"]');
  title_input.val(collection_titles[collection_id]);
  title_input = form.find('textarea[name="collection[description][]"]');
  title_input.val(collection_descs[collection_id]);
}

function open_share_my_collection_modal(element) {
  $el = $(element);
  post_url = $el.data('post-url');
  share_url = $el.data('share-url');

  // Set form submission URL on form
  $($el.data('target')).find('form').attr('action', post_url);
  // Set clipboard text
  $('#share-link').val(share_url);
  $('#unshare-link').val(share_url);
}

function open_export_my_collection_modal(element) {
  $el = $(element);
  url = $el.data('export-url');
  console.log(url);
  console.log($('#collection-export-container').find('a.btn.btn-primary'));

  // Set form submission URL on form
  $('#collection-export-container').find('a').attr('href', url);
}

// Delete modal open callback
function open_delete_my_collection_modal(element) {
  $el = $(element);
  url = $el.data('delete-url');

  // Set form submission URL on form
  $('#collection-delete-container').find('form').attr('action', url);
}
// Delete modal submission callback
function submit_delete_my_collection_modal(event) {
  // Prevent regular submission
  event.preventDefault();

  // Perform async call and alert user this may take some time
  $.ajax({
    method: "DELETE",
    async: true,
    timeout: 100,
    url: event.target.action,
    complete: function(jqXHR, status) {
      alert('Your collection is being deleted. Please give us time to process this request');
    }
  });
}

// Create modal submission callback
function submit_create_my_collection_modal(event) {
  // Prevent regular submission
  event.preventDefault();

  let type = event.target.elements['type'].value;
  let collection_type_gid = event.target.elements['collection_type_gid'].value;
  let collection_title = [];
  let collection_description = [];
  let batch_ids = [];

  $(event.target.elements['collection[title][]']).each(function() {
    collection_title.push(this.value)
  });
  $(event.target.elements['collection[description][]']).each(function() {
    collection_description.push(this.value)
  });
  $(event.target.elements['batch_document_ids[]']).each(function() {
    batch_ids.push(this.value)
  });
  $('#collection-create-container').modal('hide')

  // Perform async call and alert user this may take some time
  $.ajax({
    method: "POST",
    async: true,
    timeout: 100,
    url: event.target.action,
    data: {"collection": {"title": collection_title, "description": collection_description}, "batch_document_ids": batch_ids, "collection_type_gid": collection_type_gid, "type": type},
    complete: function(jqXHR, status) {
      alert('Your collection is being created. Please give us time to process this request');
    }
  });
}
