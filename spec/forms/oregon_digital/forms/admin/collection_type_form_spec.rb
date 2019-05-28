# frozen_string_literal: true

RSpec.describe OregonDigital::Forms::Admin::CollectionTypeForm do
  let(:collection_type) { Hyrax::CollectionType.new }
  let(:form) { described_class.new }

  it { expect(form).to delegate_method(:facet_configurable).to(:collection_type) }
end
