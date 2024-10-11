Blacklight.onLoad(function() {
  if($('#importer-show-table').length) {
    $('#importer-show-table').DataTable( {
      'processing': true,
      'serverSide': true,
      "ajax": window.location.href.replace(/(\/(importers|exporters)\/\d+)/, "$1/entry_table.json"),
      /* Add in default of using 'last run' as sorting mechanism */

      'order': [[2, 'asc']],
      /* customize default page length and menu */
      "pageLength": 10,
      "lengthMenu": [[10, 25, 50], [10, 25, 50]],
      "columns": [
        { "data": "identifier" },
        { "data": "id" },
        { "data": "status_message" },
        { "data": "type" },
        { "data": "updated_at" },
        { "data": "errors", "orderable": false },
        { "data": "actions", "orderable": false }
      ],
      initComplete: function () {
        // Add entry class filter
        entrySelect.bind(this)()
        // Add status filter
        statusSelect.bind(this)()
        // Add refresh link
        refreshLink.bind(this)()
      }
    } );
  }

    if($('#importers-table').length) {
    $('#importers-table').DataTable( {
      'processing': true,
      'serverSide': true,
      "ajax": window.location.href.replace(/(\/importers)/, "$1/importer_table.json"),
      /* Add in default of using 'last run' as sorting mechanism */

      'order': [[2, 'asc']],
      /* customize default page length and menu */
      "pageLength": 10,
      "lengthMenu": [[10, 25, 50], [10, 25, 50]],
      "columns": [
        { "data": "name" },
        { "data": "status_message" },
        { "data": "last_imported_at" },
        { "data": "next_import_at" },
        { "data": "enqueued_records", "orderable": false },
        { "data": "processed_records", "orderable": false },
        { "data": "failed_records", "orderable": false },
        { "data": "deleted_records", "orderable": false },
        { "data": "total_collection_entries", "orderable": false },
        { "data": "total_work_entries", "orderable": false },
        { "data": "total_file_set_entries", "orderable": false },
        { "data": "actions", "orderable": false }
      ],
      initComplete: function () {
        // Add status filter
        statusSelect.bind(this)()
        // Add refresh link
        refreshLink.bind(this)()
      }
    } );
  }

  if($('#exporters-table').length) {
    $('#exporters-table').DataTable( {
      'processing': true,
      'serverSide': true,
      "ajax": window.location.href.replace(/(\/exporters)/, "$1/exporter_table.json"),
      "pageLength": 30,
      "lengthMenu": [[30, 100, 200], [30, 100, 200]],
      "columns": [
        { "data": "name" },
        { "data": "status_message" },
        { "data": "created_at" },
        { "data": "download", "orderable": false },
        { "data": "actions", "orderable": false }
      ],
      initComplete: function () {
        // Add status filter
        statusSelect.bind(this)()
        // Add refresh link
        refreshLink.bind(this)()
      }
    } );
  }

})

function entrySelect() {
  let entrySelect = document.createElement('select')
  entrySelect.id = 'entry-filter'
  entrySelect.classList.value = 'form-control input-sm'
  entrySelect.style.marginRight = '10px'

  entrySelect.add(new Option('Filter by Entry Class', ''))
  // Read the options from the footer and add them to the entrySelect
  $('#importer-entry-classes').text().split('|').forEach(function (col, i) {
    entrySelect.add(new Option(col.trim()))
  })
  document.querySelector('div#importer-show-table_filter').firstChild.prepend(entrySelect)

  // Apply listener for user change in value
  entrySelect.addEventListener('change', function () {
    var val = entrySelect.value;
    this.api()
      .search(val ? val : '', false, false)
      .draw();
  }.bind(this));
}

function statusSelect() {
  let statusSelect = document.createElement('select');
  statusSelect.id = 'status-filter'
  statusSelect.classList.value = 'form-control input-sm'
  statusSelect.style.marginRight = '10px'

  statusSelect.add(new Option('Filter by Status', ''));
  statusSelect.add(new Option('Complete'))
  statusSelect.add(new Option('Pending'))
  statusSelect.add(new Option('Failed'))
  statusSelect.add(new Option('Skipped'))
  statusSelect.add(new Option('Deleted'))
  statusSelect.add(new Option('Complete (with failures)'))

  document.querySelector('div.dataTables_filter').firstChild.prepend(statusSelect)

  // Apply listener for user change in value
  statusSelect.addEventListener('change', function () {
    var val = statusSelect.value;
    this.api()
      .search(val ? val : '', false, false)
      .draw();
  }.bind(this));
}

function refreshLink() {
  let refreshLink = document.createElement('a');
  refreshLink.onclick = function() {
    this.api().ajax.reload(null, false)
  }.bind(this)
  refreshLink.classList.value = 'fa fa-refresh'
  refreshLink.style.marginLeft = '10px'
  document.querySelector('div.dataTables_filter').firstChild.append(refreshLink)
}

