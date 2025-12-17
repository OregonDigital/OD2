# frozen_string_literal: true

RSpec.describe OregonDigital::VerifyLabelsService do
  let(:work) { create(:generic) }
  let(:photographer) { double }
  let(:illustrator) { double }
  let(:service) { described_class.new({ work: work, solr_doc: solr_doc }) }
  let(:solr_doc) do
    {
      'id' => 'abcde1234',
      'photographer_parsable_label_ssim' => ['Jim Lemke$http://opaquenamespace.org/ns/creators/LemkeJim'],
      'rights_statement_parsable_label_ssim' => ['In Copyright$https://rightsstatement.org/vocab/InC/1.0'],
      'resource_type_parsable_label_ssim' => ['Text$http://purl.org/dc/dcmitype/Text']
    }
  end

  before do
    allow(work).to receive(:photographer).and_return([photographer])
    allow(work).to receive(:illustrator).and_return([illustrator])
  end

  describe 'verify' do
    context 'when labels have been fetched' do
      before do
        solr_doc['illustrator_parsable_label_ssim'] = ['SJ Rabun$http://opaquenamespace.org/ns/creators/RabunSJ']
      end

      it 'finds no errors' do
        expect(service.verify).to eq(labels: [])
      end
    end

    context 'when labels are missing' do
      before do
        solr_doc['illustrator_parsable_label_ssim'] = ['$http://opaquenamespace.org/ns/creators/RabunSJ']
      end

      it 'returns the URI missing a label' do
        expect(service.verify).to eq(labels: [{ 'illustrator' => ['http://opaquenamespace.org/ns/creators/RabunSJ'] }])
      end
    end
  end
end
