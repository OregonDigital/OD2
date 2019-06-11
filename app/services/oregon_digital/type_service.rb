# frozen_string_literal: true

module OregonDigital
  # Provide select options for the license (dcterms:rights) field
  class TypeService < Hyrax::QaSelectService
    def initialize
      super('resource_types')
    end

    def all_labels(values)
      puts "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
      puts @authority.all.select { |r| puts r['id'] == values }
      @authority.all.select { |r| r['id'] == values }.map { |hash| hash['label'] }.first
    end

    def select_sorted_all_options
      select_all_options.sort
    end
  end
end
