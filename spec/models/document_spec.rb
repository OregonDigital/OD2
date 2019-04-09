# frozen_string_literal:true

RSpec.describe Document do
  subject { model }

  let(:model) { build(:document, title: ['foo']) }
  let(:props) { Document.document_properties.map(&:to_sym) }

  it { is_expected.to have_attributes(title: ['foo']) }

  describe 'metadata' do
    it 'has descriptive metadata' do
      props.each do |prop|
        expect(model).to respond_to(prop)
      end
    end
  end
end
