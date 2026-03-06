$(document).ready(function () {
  $('.advanced-search-facet-select').chosen({
    allow_single_deselect: true,
    max_shown_results: 10000,
    no_results_text: 'No results matched',
    width: '100%'
  });
});