require 'rails_helper'

RSpec.describe OregonDigital::TriplePoweredProperties::TriplePoweredForm do
  describe "#has_triple_powered_property?" do
    let(:form) { Hyrax::GenericForm.new(Generic.new({ based_near: [ url ], title: ['TestTest'] }), instance_double("Ability"), instance_double("Controller")) }
    let(:url) { 'http://opaquenamespace.org/ns/TestVocabulary/TestTerm' }
    it "should return a truthy statement if it has a triple powered property" do
      expect(form.has_triple_powered_property?(:based_near)).to eq true
    end
    it "should return a falsey statement if it does not have a triple powered property" do
      expect(form.has_triple_powered_property?(:anything_else)).to eq false
    end
  end
end