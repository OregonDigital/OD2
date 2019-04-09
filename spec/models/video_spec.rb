# frozen_string_literal:true

RSpec.describe Video do
  subject { build(:video, title: ['foo']) }

  let(:model) { subject }
  let(:props) { Video.video_properties.map(&:to_sym) }

  it { is_expected.to have_attributes(title: ['foo']) }
  it { is_expected.to have_attributes(height: '100') }
  it { is_expected.to have_attributes(width: '200') }

  describe 'metadata' do
    it 'has descriptive metadata' do
      props.each do |prop|
        expect(model).to respond_to(prop)
      end
    end
  end
end
