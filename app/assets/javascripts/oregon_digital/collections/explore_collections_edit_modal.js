$(document).ready(function() {
  // Show loading gif and hide the form when edit collection modal closes
  $('#collection-edit-container').on('hidden.bs.modal', function(e) {
    $('.loading', this).show();
    $('.form', this).hide();
  });

  // Reorganize masonry after collapsable actions exapand or collapse
  $("[data-behavior='masonry-gallery']").on('shown.bs.collapse', function(e) {
    $(this).masonry({
      transitionDuration: '250ms'
    });
  });
  $("[data-behavior='masonry-gallery']").on('hidden.bs.collapse', function(e) {
    $(this).masonry({
      transitionDuration: '250ms'
    });
  });
});

function open_edit_modal(collection_id) {
  $('#collection-edit-container .modal-content .modal-body .form').load('/dashboard/collections/' + collection_id + '/edit #edit_collection_' + collection_id, function() {
    // Move the terms and save button out of the tab panel
    var terms = $('#base-terms');
    var save = $('#update_submit');
    $('#edit_collection_' + collection_id).append(terms).append(save);
    $('#edit_collection_' + collection_id + ' .tab-content').remove();

    // Turn the fields into mutli_value fields
    $('.multi_value.form-group').manage_fields();

    // Toggle loading gif and form
    $('#collection-edit-container .loading').hide();
    $('#collection-edit-container .form').show();
  });
}