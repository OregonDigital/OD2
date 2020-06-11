function updateSaveCheckboxes (button) {
  $('input[type=checkbox]').each(function() {
    if (this.id.includes(button.dataset.id)) {
      this.checked = true;
    } else {
      this.checked = false;
    }
  });
}