# frozen_string_literal: true

# methods for making it easier
# copied from Bulkrax::ApplicationHelper
module BulkraxHelper
  def item_entry_path(item, e, opts = {})
    an_importer?(item) ? bulkrax.importer_entry_path(item.id, e.id, opts) : bulkrax.exporter_entry_path(item.id, e.id, opts)
  end

  def an_importer?(item)
    item.class.to_s.include?('Importer')
  end

  def coderay(value, opts)
    CodeRay
      .scan(value, :ruby)
      .html(opts)
      .html_safe
  end
end
