# frozen_string_literal:true

RSpec.describe OregonDigital::TriplePoweredProperties::TriplePoweredForm do
  describe '#triple_powered_property?' do
    let(:form) { Hyrax::GenericForm.new(Generic.new(based_near: [url], title: ['TestTest']), instance_double('Ability'), instance_double('Controller')) }
    let(:url) { 'http://opaquenamespace.org/ns/TestVocabulary/TestTerm' }

    it 'returns a truthy statement if it has a triple powered property' do
      expect(form.triple_powered_property?(:based_near)).to eq true
    end
    it 'returns a falsey statement if it does not have a triple powered property' do
      expect(form.triple_powered_property?(:anything_else)).to eq false
    end
  end
end
