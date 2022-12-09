$(document).ready(function() {
  $("[data-behavior='masonry-gallery']").masonry({
    transitionDuration: 5,
    columnWidth: '#masonry-sizer',
    gutter: '#masonry-gutter-sizer',
    horizontalOrder: true,
  });
});
