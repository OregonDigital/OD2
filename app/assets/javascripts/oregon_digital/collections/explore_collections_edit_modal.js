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