// ON LOAD: When page load, fetch the current URL to redirect
$(function () {
    $('#return_to_page').val(window.location.href);
});