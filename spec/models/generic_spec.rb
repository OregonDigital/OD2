# frozen_string_literal:true

RSpec.describe Generic do
  subject { model }

  let(:model) { build(:generic, title: ['foo'], depositor: user.email, id: 123) }
  let(:props) { described_class.generic_properties.map(&:to_sym) }
  let(:user) { create(:user) }
  let(:uri) { RDF::URI.new('http://opaquenamespace.org/ns/TestVocabulary/TestTerm') }
  let(:term) { OregonDigital::ControlledVocabularies::Resource.new }
  let(:file_uri) { 'https://uri' }
  let(:file) { instance_double('file', stream: ["\x00"], file_name: ['name'], uri: OpenStruct.new(value: file_uri)) }
  let(:file_set) { instance_double('file_set', files: [file]) }

  it { is_expected.to have_attributes(title: ['foo']) }
  it { expect(described_class.generic_properties.include?('tribal_title')).to eq true }
  it { expect(described_class.generic_properties.include?('based_near')).to eq false }
  it { expect(described_class.controlled_properties.include?(:genus)).to eq true }

  describe 'metadata' do
    it 'has descriptive metadata' do
      props.each do |prop|
        expect(model).to respond_to(prop)
      end
    end
  end

  describe '#controlled_property_to_csv_value' do
    before do
      allow(term).to receive(:fetch)
      allow(term).to receive(:solrize).and_return(['http://opaquenamespace.org/ns/TestVocabulary/TestTerm', { label: 'TestTerm$http://opaquenamespace.org/ns/TestVocabulary/TestTerm' }])
    end

    it 'formats a controlled property' do
      expect(model.send(:controlled_property_to_csv_value, term)).to eq('TestTerm')
    end
  end

  describe '#controlled_properties_as_s' do
    it 'tries to format all controlled properties' do
      model.controlled_properties.map { |prop| expect(model).to receive(prop.to_s) }
      model.send(:controlled_properties_as_s)
    end
    it 'returns an empty hash with no controlled properties' do
      expect(model.send(:controlled_properties_as_s)).to eq({})
    end
  end

  describe '#properties_as_s' do
    it 'tries to format the correct properties' do
      rejected_fields = %w[head tail] + model.controlled_properties.map(&:to_sym)
      (model.send(:properties).keys - rejected_fields).map { |prop| expect(model).to receive(prop.to_s) }
      model.send(:properties_as_s)
    end
    it 'returns a hash with no controlled properties' do
      expect(model.send(:properties_as_s)).to eq(depositor: user.email, has_model: 'Generic', resource_type: 'MyType', title: 'foo', identifier: 'MyIdentifier', rights_statement: 'http://rightsstatements.org/vocab/InC/1.0/')
    end
  end

  describe '#csv_metadata' do
    it 'provides a string' do
      expect(model.csv_metadata).to be_kind_of(String)
    end
    it 'provides correct data' do
      csv = CSV.parse(model.csv_metadata, headers: true)
      expect(csv[0].to_h).to eq('depositor' => user.email, 'has_model' => 'Generic', 'resource_type' => 'MyType', 'title' => 'foo', 'identifier' => 'MyIdentifier', 'rights_statement' => 'http://rightsstatements.org/vocab/InC/1.0/')
    end
  end
end
