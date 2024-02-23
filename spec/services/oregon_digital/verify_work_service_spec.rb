# frozen_string_literal: true

RSpec.describe OregonDigital::VerifyWorkService do
  let(:service) { described_class.new(args) }
  let(:args) { { pid: pid } }
  let(:work) { build(:image, id: pid, title: ['Picky Eater']) }
  let(:solr_doc) { SolrDocument.new(attributes) }
  let(:derivs_verify) { double }
  let(:attributes) do
    {
      'title_tesim' => [],
      'has_model_ssim' => ['Image']
    }
  end
  let(:pid) { 'abcde1234' }
  let(:message) { 'Houston, we have a midlife crisis' }

  before do
    allow(SolrDocument).to receive(:find).and_return(solr_doc)
    allow(Hyrax.query_service).to receive(:find_by_alternate_identifier).and_return(work)
    allow(OregonDigital::VerifyDerivativesService).to receive(:new).and_return(derivs_verify)
    allow(derivs_verify).to receive(:verify).and_return({ derivs: [message] })
  end

  after do
    work.remove_errors(:derivs)
  end

  describe 'running the service when there are errors' do
    it 'adds the error to the work' do
      service.run
      expect(work.all_errors[:derivs]).to include(message)
    end
  end

  describe 'running the service with a custom list of services' do
    let(:args) { { pid: pid, verify_services: ['DummyVerify'] } }
    let(:dummy) { double }

    before do
      stub_const 'DummyVerify', Class.new
      DummyVerify.class_eval do
        def initialize(work); end

        def verify; end
      end
      allow(DummyVerify).to receive(:new).and_return(dummy)
      allow(dummy).to receive(:verify).and_return({ dummy: [message] })
    end

    after do
      work.remove_errors(:dummy)
    end

    it 'instantiates DummyVerify' do
      expect(DummyVerify).to receive(:new)
      expect(OregonDigital::VerifyDerivativesService).not_to receive(:new)
      service.run
    end
  end
end
