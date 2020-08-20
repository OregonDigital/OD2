$(document).ready(function() {
  $('a[data-toggle="pill"]').on('shown.bs.tab', function(e) {
    // Reload masonry view for tabbed content and remove transition animation
    $("[data-behavior='masonry-gallery']").masonry({
      transitionDuration: 0,
      gutter: 35
    });
  });
});
