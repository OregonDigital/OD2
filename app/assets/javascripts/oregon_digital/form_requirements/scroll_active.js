// LOAD: Create the active scroll for the form progression
$(function () {
  // SETUP: Get the link and map out href area
  const toc_links = $(".toc-link");
  const sections = [];

  toc_links.each(function () {
    const target = $($(this).attr("href"));
    if (target.length) { sections.push(target); }
  });

  // SCROLL: Use scroll event for highlight link
  $(window).on("scroll", function () {
    let current_loc = null;
    const scrollPos = $(window).scrollTop();

    sections.forEach(function ($section) {
      if ($section.offset().top <= scrollPos + 120) {
        current_loc = $section.attr("id");
      }
    });

    // REMOVE: Once scroll away, remove the active tab and make current one active instead
    toc_links.removeClass("active");
    if (current_loc) {
      toc_links.filter('[href="#' + current_loc + '"]').addClass("active");
    }
  });

  // TRIGGER: Trigger scroll once on page load to set initial active link
  $(window).trigger("scroll");
});
