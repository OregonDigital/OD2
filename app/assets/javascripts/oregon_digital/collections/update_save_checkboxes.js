function updateSaveCheckboxes (button) {
  $('input[type=checkbox]').each(function() {
    alert(this.id)
    if (this.id.includes(button.dataset.id)) {
      alert('checked')
      this.checked = true;
    } else {
      this.checked = false;
    }
  });
}