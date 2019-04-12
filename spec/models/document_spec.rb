# frozen_string_literal:true

RSpec.describe Document do
  subject { model }

  let(:model) { build(:document, title: ['foo']) }
  let(:props) { described_class.document_properties.map(&:to_sym) }

  it { is_expected.to have_attributes(title: ['foo']) }
  it { expect(described_class.document_properties.include?('is_volume')).to eq true }
  it { expect(described_class.document_properties.include?('title')).to eq false }

  describe 'metadata' do
    it 'has descriptive metadata' do
      props.each do |prop|
        expect(model).to respond_to(prop)
      end
    end
  end
end
