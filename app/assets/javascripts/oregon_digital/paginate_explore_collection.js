$(document).ready(function() {
  $('#explore-collection-table').DataTable({
    pageLength: 4,
    lengthMenu: [[ 4 ],[ "4" ]],
    ordering: false
  });
});