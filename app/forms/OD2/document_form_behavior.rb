module OD2
  module DocumentFormBehavior
    extend ActiveSupport::Concern
    included do
      self.terms += [
        :contained_in_journal, :first_line, :first_line_chorus, :has_number, :host_item,
        :instrumentation, :is_volume, :larger_work, :number_of_pages, :table_of_contents
      ]
    end
  end
end
