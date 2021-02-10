// Display all checkboxes that are already checked on page load
$(document).ready(function() {
  boxes = $('.hyc-bl-results.hyc-bl-search p :checked');
  boxes.each(function() {
    $(this).parent().addClass('checked');
  });
} );

// Recalculate the checkbox display state
function setGalleryCheckbox(checkbox) {
  box = $(checkbox);
  wrapper = box.parent();
  wrapper.removeClass('checked');
  if (box.prop('checked') || box.is(':focus')) {
    wrapper.addClass('checked');
  }
}