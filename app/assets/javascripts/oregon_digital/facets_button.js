// ON LOAD: When page refresh, it will switch on click for the label on facets display button
$(function() {
  // CHANGE: On click, change the button label between 'More' and 'Less'
  $('.secondary-facets, .secondary-advanced-facets').on('click', function() {
    // DECLARE: Get the modify text
    const moreText = $(this).data('more-text');
    const lessText = $(this).data('less-text');
    
    // CHECK: Get the current text and check the value to switch on display when click  
    const currentText = $.trim($(this).text());
    $(this).text(currentText === moreText ? lessText : moreText);
  });
});
