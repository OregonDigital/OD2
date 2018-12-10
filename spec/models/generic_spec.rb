# frozen_string_literal:true

RSpec.describe Generic do
  subject { model }

  let(:model) { build(:generic, title: ['foo']) }
  let(:props) { OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym) }

  it { is_expected.to have_attributes(title: ['foo']) }

  describe 'metadata' do
    it 'has descriptive metadata' do
      props.each do |prop|
        expect(model).to respond_to(prop)
      end
    end
  end
end
