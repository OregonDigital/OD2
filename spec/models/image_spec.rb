# Generated via
#  `rails generate hyrax:work Image`
require 'rails_helper'

RSpec.describe Image do
  let(:props) {OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym)}

  it 'has a title' do
    subject.title = ['foo']
    expect(subject.title).to eq ['foo']
  end

  it 'has a colour_content' do
    subject.colour_content = ['Color']
    expect(subject.colour_content).to eq ['Color']
  end

  it 'has a color_space' do
    subject.color_space = ['RGB']
    expect(subject.color_space).to eq ['RGB']
  end

  it 'has a height' do
    subject.height = '100'
    expect(subject.height).to eq '100'
  end

  it 'has an orientation' do
    subject.orientation = ['Horizontal']
    expect(subject.orientation).to eq ['Horizontal']
  end

  it 'has an photograph_orientation' do
    subject.photograph_orientation = 'west'
    expect(subject.photograph_orientation).to eq 'west'
  end

  it 'has an photograph_orientation' do
    subject.resolution = '72'
    expect(subject.resolution).to eq '72'
  end

  it 'has an view' do
    subject.view = ['exterior']
    expect(subject.view).to eq ['exterior']
  end

  it 'has an width' do
    subject.width = '200'
    expect(subject.width).to eq '200'
  end

  describe "metadata" do
    it "has descriptive image metadata" do
      expect(subject).to respond_to(:colour_content)
      expect(subject).to respond_to(:color_space)
      expect(subject).to respond_to(:height)
      expect(subject).to respond_to(:orientation)
      expect(subject).to respond_to(:photograph_orientation)
      expect(subject).to respond_to(:resolution)
      expect(subject).to respond_to(:view)
      expect(subject).to respond_to(:width)
    end

    it "has descriptive generic metadata" do
      props.each do |prop|
        expect(subject).to respond_to(prop)
      end
    end
  end
end
