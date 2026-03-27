// Bulkrax is using $().on('ready') syntax which was deprecated when they wrote it and removed in jQuery v3
$(document).ready(prepBulkrax);

// Update Bootstrap classes for Bulkrax form controls on dashboard
function statusSelect() {
  let statusSelect = document.createElement('select');
  statusSelect.id = 'status-filter'
  statusSelect.classList.value = 'form-control-sm d-sm-block d-md-inline-block'
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
