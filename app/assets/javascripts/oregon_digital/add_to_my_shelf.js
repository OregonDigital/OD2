$( document ).ready(function() {
  $('#Select_all_on_page').click(function() {
    var all_on_page_state = this.checked;
    $('.my_shelf_result_checkbox').each(function () { this.checked = all_on_page_state; });
  });
});