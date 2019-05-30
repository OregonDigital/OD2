$('#sortable_facets').ready(function () {
  $('#sortable_facets').sortable({
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
