# frozen_string_literal:true

RSpec.describe Generic do
  subject { model }

  let(:model) { build(:generic, title: ['foo'], depositor: user.email) }
  let(:props) { described_class.generic_properties.map(&:to_sym) }
  let(:user) { create(:user) }
  let(:uri) { RDF::URI.new('http://opaquenamespace.org/ns/TestVocabulary/TestTerm') }

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

  describe '#enqueue_fetch_failure' do
    before do
      allow(Hyrax.config.callback).to receive(:run)
      allow(FetchGraphWorker).to receive(:perform_in)
      stub_request(:post, 'http://ci-test:8080/bigdata/namespace/rw/sparql')
        .to_return(status: 200, body: '', headers: {})
      # model.depositor = user.email
    end
    it 'emails the user' do
      expect(Hyrax.config.callback).to receive(:run).with(:ld_fetch_error, user, uri)
      model.send(:enqueue_fetch_failure, uri)
    end
    it 'enqueues a retry job' do
      expect(FetchGraphWorker).to receive(:perform_in).with(15.minutes, uri, user)
      model.send(:enqueue_fetch_failure, uri)
    end
  end
end
