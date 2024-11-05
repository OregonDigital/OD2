// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//

// Required by Blacklight
//= require jquery
//= require chosen-jquery
//= require 'blacklight_advanced_search'

// Required by browse-everything. requireing all of browse-everything causes bootstrap to be included twice
//= require jquery.treetable
//= require browse_everything/behavior

//= require jquery_ujs
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require blacklight/blacklight

//= require_directory .
//= require bulkrax/application
//= require_tree ./oregon_digital
//= require hyrax

// Required for Hyrax override in assets/javascripts/hyrax/editor/controlled_vocabulary.es6
//= require handlebars-v4.0.5


// For blacklight_range_limit built-in JS, if you don't want it you don't need
// this:
//= require 'blacklight_range_limit'

//= require cookieconsent
