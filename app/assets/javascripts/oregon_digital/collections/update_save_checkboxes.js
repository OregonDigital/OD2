function max_checked(e) {
  if ($('input[type=checkbox]:checked').length > 10) {
    alert ("You can only save 10 items at a time. Please save your current selections and continue afterwords.")
    e.checked = false;
  }
}


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