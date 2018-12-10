# frozen_string_literal:true

RSpec.describe OembedError, type: :model do
  subject { model }

  let(:model) { build(:oembed_error, oembed_errors: ['ERROR ERROR ERROR']) }
  let(:error) { 'ERROR ERROR ERROR' }

  before do
    model.oembed_errors << error
  end

  it { expect(model.oembed_errors).to be_an_instance_of(Array) }
  it { expect(model.oembed_errors.count).to eq(2) }

  it 'prevents error duplication' do
    model.run_callbacks :save
    expect(model.oembed_errors.count).to eq(1)
  end
end
