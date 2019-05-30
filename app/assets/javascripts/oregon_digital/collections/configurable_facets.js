// Add keyboard controls to jQuery.sortable()
jQuery.fn.extend({
  ksortable: function (options) {
    this.sortable(options);
    $('li', this).attr('tabindex', 0).bind('keydown', function (event) {
      if (event.which == 37 || event.which == 38) { // left or up
        $(this).insertBefore($(this).prev());
        $(this).focus();
      }
      if (event.which == 39 || event.which == 40) { // right or down
        $(this).insertAfter($(this).next());
        $(this).focus();
      }
      if (event.which == 33) { // page-up
        $(this).parent().prepend($(this));
        $(this).focus();
      }
      if (event.which == 34) { // page-down
        $(this).parent().append($(this));
        $(this).focus();
      }
    });
  }
});

$('#sortable_facets').ready(function () {
  $('#sortable_facets').ksortable({
    revert: 100,
    axis: 'y',
    containment: '#sortable_facets',
    handle: '.handle',
    tolerance: 'touch',
    update: function (e, ui) {
      console.log($('#sortable_facets').sortable('serialize'));
      $('#facet_configuration').val($('#sortable_facets').sortable('serialize'));
    }
  });
  $('#sortable_facets').disableSelection();

  $('form').submit(function () {
    $('#facet_configuration').val($('#sortable_facets').sortable('serialize'));
  });
});
