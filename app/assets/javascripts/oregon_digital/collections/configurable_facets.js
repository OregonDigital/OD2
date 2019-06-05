// Add keyboard controls to jQuery.sortable()
jQuery.fn.extend({
  ksortable: function (options) {
    this.sortable(options);
    $('li', this).attr('tabindex', 0).bind('keydown', function (event) {
      // Quit out if focus is in a child element (form inputs)
      if (event.currentTarget != event.target) return;
      // Overwrite default behavior so users aren't scrolling all over the place
      // Quit out if this isn't a key we care about
      switch(event.which) {
        case 32: //space
        case 13: //enter
        case 37: //left
        case 38: //up
        case 39: //right
        case 40: //down
        case 33: //page-up
        case 34: //page-down
          event.preventDefault();
          break;
        default:
          return;
      }

      // Select this element, show the user, and stop spamming aria-describedby on move
      if (event.which == 32 || event.which == 13) { // spacebar or enter
        $(this).toggleClass('facet-selected');
        $(this).attr('aria-describedby', function(i, attr) {
          return attr == 'facets-instructions' ? '' : 'facets-instructions';
        });
      }

      // Only apply changes if the element is selected
      if ($(this).hasClass('facet-selected')) {
        if (event.which == 37 || event.which == 38) { // left or up
          $(this, 'label')
          $(this).insertBefore($(this).prev());
        }
        if (event.which == 39 || event.which == 40) { // right or down
          $(this).insertAfter($(this).next());
        }
        if (event.which == 33) { // page-up
          $(this).parent().prepend($(this));
        }
        if (event.which == 34) { // page-down
          $(this).parent().append($(this));
        }
        $(this).focus();
        updateLive(this);
      }

      // Update the aria-live element to describe the current element and it's position in the list
      function updateLive(elem) {
        itemLabel = $($(elem).children('label')[0]).text();
        listCount = $(elem).parent().children('li').length;
        listIndex = $(elem).parent().children('li').index(elem) + 1;
        $('#facets-live').text(itemLabel +' grabbed. Position in list: ' + 'listIndex' + ' of ' + listCount);
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
