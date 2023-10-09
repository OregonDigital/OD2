// FUNCTION: Create a default filter 
$(function() {
  // GET: Fetch out the id of the index page
  var id_val = $('.table-responsive').attr('id');
  
  if (id_val == 'import-table') {
    $('#DataTables_Table_0').DataTable({
      destroy: true, /* Reinitialize DataTable with config below */
      'columnDefs': [
          { 'orderable': true, 'targets': [...Array(10).keys()] },
          { 'orderable': false, 'targets': [10, 11, 12] }
      ],
      'order': [[2, 'desc']], /* Add in default of using 'last run' as sorting mechanism */
      'language': {
        'info': 'Showing _START_ to _END_ of _TOTAL_ importers',
        'infoEmpty': 'No importers to show',
        'infoFiltered': '(filtered from _MAX_ total importers)',
        'lengthMenu': 'Show _MENU_ importers'
      }
    })
  }

  else {
    $('#DataTables_Table_0').DataTable({
      destroy: true, /* Reinitialize DataTable with config below */
      'columnDefs': [
          { 'orderable': true, 'targets': [0, 1, 2] },
          { 'orderable': false, 'targets': [3, 4, 5, 6] }
      ],
      'order': [[2, 'desc']], /* Add in default of using 'date exported' as sorting mechanism */
      'language': {
        'info': 'Showing _START_ to _END_ of _TOTAL_ exporters',
        'infoEmpty': 'No exporters to show',
        'infoFiltered': '(filtered from _MAX_ total exporters)',
        'lengthMenu': 'Show _MENU_ exporters'
      }
    })
  }
})