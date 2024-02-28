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

  describe '#metadata_row' do
    it 'provides an array' do
      expect(model.metadata_row([:title], [])).to be_kind_of(Array)
    end
    it 'provides correct data' do
      data = model.metadata_row(%i[depositor has_model resource_type title identifier rights_statement], [])
      expect(data).to eq([user.email, 'Generic', 'Text', 'foo', 'MyIdentifier', 'In Copyright'])
    end
  end
end
