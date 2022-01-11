function updateSaveCheckboxes (button) {
  $('input[type=checkbox]').each(function() {
    if (this.id.includes(button.dataset.id)) {
      this.checked = true;
    } else {
      this.checked = false;
    }
  });
}

function selectAllSearchResults() {
  $('input[type=checkbox]').each(function() {
    this.checked = true;
  });
  $('#select-chosen').text("Selected All")
}

function deselectAllSearchResults() {
  $('input[type=checkbox]').each(function() {
    this.checked = false;
  });
  $('#select-chosen').text("Deselected All")
}