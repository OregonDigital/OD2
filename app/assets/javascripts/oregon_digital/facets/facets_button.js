// ON LOAD: When page refresh, it will switch on click for the label on facets display button
$(function () {
  // CHANGE: On click, change the button label between 'More' and 'Less'
  $(".secondary-facets, .secondary-advanced-facets").on("click", function () {
    // DECLARE: Get the modify text
    const moreText = $(this).data("more-text");
    const lessText = $(this).data("less-text");

    // CHECK: Get the current text and check the value to switch on display when click
    const currentText = $.trim($(this).text());
    $(this).text(currentText === moreText ? lessText : moreText);
  });
});

// ON LOAD: When page load, activate the switching of button click on modal
$(function () {
  // CHANGE: On click, change the behavior of the button when close facet
  $("#modal-close-btn").on("click", function (event) {
    // DECLARE: Get the URL currently on page
    const url = new URL(window.location.href);

    // CONDITION: If URL contain facet
    if (url.pathname.indexOf('/facet/') !== -1) {
      // Override the original Bootstrap
      event.preventDefault();

      // STRIP: Strip the URL for base URL
      const base_url = url.pathname.split('/facet/')[0];

      // CLONE: Clone search params
      const params = new URLSearchParams(url.search);
      // REMOVE: Remove facet-specific params
      params.delete('facet.page');

      // REDIRECT: Redirect with preserved params
      const queryString = params.toString();
      window.location.href = base_url + (queryString ? '?' + queryString : '');
    }

    // ELSE: Do it normally with the Bootstrap
  });
});
