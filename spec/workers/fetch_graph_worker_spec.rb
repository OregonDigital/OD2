# frozen_string_literal: true

require 'rails_helper'
RSpec.describe FetchGraphWorker, type: :worker do
  let(:worker) { described_class.new }
  let(:uri) { 'http://my.queryuri.com' }
  let(:user) { build(:user) }

  describe '#triplestore' do
    it { expect(worker.triplestore).to be_a(TriplestoreAdapter::Triplestore) }
  end

  describe '#perform' do
    before do
      worker.triplestore = double
    end

    it 'attempts a local and remote fetch' do
      expect(worker.triplestore).to receive(:fetch).twice
      worker.perform(:uri, :user)
    end
  end
end
