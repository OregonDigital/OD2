$( document ).ready(function() {
  $('#Select_all_on_page').click(function() {
    var select_object = this.checked;
    $('.my_shelf_result_checkbox').each(function () { this.checked = select_object; });
  });
});