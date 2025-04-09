# frozen_string_literal:true

RSpec.describe OregonDigital::AspaceDigitalObject do
  let(:ado) { described_class.new('abcde1234') }
  let(:solrdoc) do
    {
      'id' => 'abcde1234',
      'date_tesim' => ['1920s'],
      'archival_object_id_tesim' => ["['archival_objects/1234']"]
    }
  end

  before do
    allow(SolrDocument).to receive(:find).and_return(solrdoc)
  end

  describe 'add_date' do
    let(:resp) { {} }

    it 'returns empty hash instead of invalid date' do
        expect(ado.add_date).to eq resp
    end
  end

  describe 'linked_instance' do
    let(:resp) { { 'ref' => '/repositories/2/archival_objects/1234' } }

    it 'returns path with correct id' do
      expect(ado.linked_instance).to eq resp
    end
  end
end
