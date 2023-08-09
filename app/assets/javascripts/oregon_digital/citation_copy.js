$(document).ready(function () {
    // Init clipboard-rails button for all copy URL buttons
    var clipboard = new Clipboard('.citation-copy-button');
    // Init Bootstrap tooltips for all copy URL buttons
    $('.citation-copy-button').tooltip({
      title: 'Copy citation to clipboard'
    });
  
    // On clipboard copy success
    clipboard.on('success', function (e) {
      // Set the tool tip to 'Copied' and enable it
      $(e.trigger)
        .attr('data-original-title', 'Copied')
        .tooltip('show');
  
      // Set a timeout to hide and restore tooltip text after 1sec
      setTimeout(function () {
        $(e.trigger).tooltip('hide')
          .attr('data-original-title', 'Copy citation to clipboard');
      }, 1000);
    });
  });
