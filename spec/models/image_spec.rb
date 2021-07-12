# frozen_string_literal:true

RSpec.describe Image do
  subject { build(:image, title: ['foo']) }

  let(:model) { subject }
  let(:props) { described_class.image_properties.map(&:to_sym) }

  it { expect(described_class.image_properties.include?('title')).to eq false }
  it { is_expected.to have_attributes(title: ['foo']) }
  it { is_expected.to have_attributes(color_content: ['Color']) }
  it { is_expected.to have_attributes(photograph_orientation: 'west') }
  it { is_expected.to have_attributes(resolution: '72') }
  it { is_expected.to have_attributes(view: ['exterior']) }

  describe 'metadata' do
    it 'has descriptive metadata' do
      props.each do |prop|
        expect(model).to respond_to(prop)
      end
    end
  end
end
