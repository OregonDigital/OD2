# frozen_string_literal: true

require 'rails_helper'
RSpec.describe LinkedDataWorker, type: :worker do
  let(:worker) { described_class.new }
  let(:uri) { 'http://my.queryuri.com' }
  let(:user) { build(:user) }

  describe '#triplestore' do
    it { expect(worker.triplestore).to be_a(TriplestoreAdapter::Triplestore) }
  end

  describe '#perform' do
    before do
      worker.triplestore = double
      allow(worker).to receive(:delete_old_graph).and_return(RDF::Graph.new)
    end
    it 'attempts a fetch from the triplestore' do
      expect(worker.triplestore).to receive(:fetch).with(:uri, from_remote: true)
      worker.perform(:uri, :user)
    end
  end
end
