# frozen_string_literal: true

module OregonDigital
  # adds ability to batch works
  module ParserExportRecordSetBehavior
    def in_groups_of(size, &block)
      process(size, limited_works, work_entry_class, &block)
      process(size, limited_colls, collection_entry_class, &block)
      process(size, limited_fs, file_set_entry_class, &block)
    end

    def limited_works
      limit.zero? ? works : works.slice(0, limit)
    end

    def limited_colls
      limit.zero? ? collections : (collections.slice(0, limit - works.size) || [])
    end

    def limited_fs
      limit.zero? ? file_sets : (file_sets.slice(0, limit - (works.size + collections.size)) || [])
    end

    def process(size, items, entry_class, &block)
      arr = []
      items.each do |item|
        arr << [item.fetch('id'), entry_class.to_s]
        if arr.size == size
          block.call arr
          arr.clear
        end
      end
      block.call arr unless arr.empty?
    end
  end
end
