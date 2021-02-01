$(document).ready(function() {
  $(function () {
    $('[data-toggle="tooltip"]').tooltip()
  })
  $('#show-page-table').DataTable({
    pageLength: 2,
    lengthMenu: [[ 2 ],[ "2" ]]
  });
} );