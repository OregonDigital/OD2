# frozen_string_literal: true

require 'rails_helper'
RSpec.describe LinkedDataWorker, type: :worker do
  let(:worker) { described_class.new }
  let(:uri) { 'http://my.queryuri.com' }

  describe '#triplestore' do
    it { expect(worker.triplestore).to be_a(TriplestoreAdapter::Triplestore) }
  end

  describe '#perform' do
    it 'attempts a fetch from the triplestore' do
      triplestore = double
      worker.triplestore = triplestore

      expect(triplestore).to receive(:fetch).with(:uri, from_remote: true)

      worker.perform(:uri)
    end
  end
end
