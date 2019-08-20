$( document ).ready(function() {
  $('#Select_all_on_page').click(function() {
    $('.my_shelf_result_checkbox').each(function () { this.checked = !this.checked; });
  });
});