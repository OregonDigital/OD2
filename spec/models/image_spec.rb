# frozen_string_literal:true

RSpec.describe Image do
  subject { build(:image, title: ['foo']) }

  let(:model) { subject }
  let(:props) { OregonDigital::ImageMetadata::PROPERTIES.map(&:to_sym) }

  it { is_expected.to have_attributes(title: ['foo']) }
  it { is_expected.to have_attributes(color_content: ['Color']) }
  it { is_expected.to have_attributes(color_space: ['RGB']) }
  it { is_expected.to have_attributes(height: '100') }
  it { is_expected.to have_attributes(orientation: ['Horizontal']) }
  it { is_expected.to have_attributes(photograph_orientation: 'west') }
  it { is_expected.to have_attributes(resolution: '72') }
  it { is_expected.to have_attributes(view: ['exterior']) }
  it { is_expected.to have_attributes(width: '200') }

  describe 'metadata' do
    it 'has descriptive metadata' do
      props.each do |prop|
        expect(model).to respond_to(prop)
      end
    end
  end
end
