# Generated via
#  `rails generate hyrax:work Audio`
require 'rails_helper'

RSpec.describe Generic do
  let(:props) {OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym)}

  it 'has a title' do
    subject.title = ['foo']
    expect(subject.title).to eq ['foo']
  end

  describe "metadata" do
    it "has descriptive generic metadata" do
      props.each do |prop|
        expect(subject).to respond_to(:contributor)
      end
    end
  end
end