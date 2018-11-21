# Generated via
#  `rails generate hyrax:work Video`
require 'rails_helper'

RSpec.describe Video do
  let(:props) {OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym)}

  it 'has a title' do
    subject.title = ['foo']
    expect(subject.title).to eq ['foo']
  end

  it 'has a height' do
    subject.height = '100'
    expect(subject.height).to eq '100'
  end

  it 'has an width' do
    subject.width = '200'
    expect(subject.width).to eq '200'
  end

  describe "metadata" do
    it "has descriptive video metadata" do
      expect(subject).to respond_to(:height)
      expect(subject).to respond_to(:width)
    end

    it "has descriptive generic metadata" do
      props.each do |prop|
        expect(subject).to respond_to(prop)
      end
    end
  end
end
