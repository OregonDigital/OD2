# frozen_string_literal:true

RSpec.describe OregonDigital::TriplestoreHealth do
  let(:dummy_class) { (Class.new { include OregonDigital::TriplestoreHealth }).new }
  let(:uri) { 'http://banana.org' }
  let(:graph) { RDF::Graph.new }

  describe 'triplestore_is_alive?' do
    context 'when triplestore is running' do
      before do
        allow(OregonDigital::Triplestore).to receive(:fetch_cached_term).with(uri).and_return(RDF::Graph.new)
      end

      it 'returns true' do
        expect(dummy_class.triplestore_is_alive?(uri)).to eq true
      end
    end

    context 'when the triplestore is not reachable' do
      before do
        allow(OregonDigital::Triplestore).to receive(:fetch_cached_term).and_raise(IOError)
      end

      it 'returns false' do
        expect(dummy_class.triplestore_is_alive?(uri)).to eq false
      end
    end

    context 'when the triplestore goes partially down' do
      before do
        allow(OregonDigital::Triplestore).to receive(:fetch_cached_term).and_return(nil)
      end

      it 'returns false' do
        expect(dummy_class.triplestore_is_alive?(uri)).to eq false
      end
    end
  end
end
