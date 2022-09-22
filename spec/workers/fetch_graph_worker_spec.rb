# frozen_string_literal: true

require 'rails_helper'
RSpec.describe FetchGraphWorker, type: :worker do
  let(:worker) { described_class.new }
  let(:uri) { 'http://my.queryuri.com' }
  let(:user) { build(:user) }
  let(:model) { create(:generic, title: ['foo'], keyword: ['bar'], award_date: ['1900-12-31'], creator: [creator_controlled_val], subject: [subject_controlled_val], ranger_district: [location_controlled_val], taxon_class: [scientific_controlled_val], depositor: user.email, id: 123) }
  let(:creator_controlled_val) { OregonDigital::ControlledVocabularies::Creator.new('http://opaquenamespace.org/ns/creator/ChabreWayne') }
  let(:subject_controlled_val) { OregonDigital::ControlledVocabularies::Subject.new('http://opaquenamespace.org/ns/creator/ChabreWayne') }
  let(:location_controlled_val) { Hyrax::ControlledVocabularies::Location.new('http://opaquenamespace.org/ns/creator/ChabreWayne') }
  let(:scientific_controlled_val) { OregonDigital::ControlledVocabularies::Scientific.new('http://opaquenamespace.org/ns/genus/Acnanthes') }
  let(:work) { model }

  describe '#perform' do
    context 'when the request works' do
      before do
        allow_any_instance_of(Hyrax::ControlledVocabularies::Location).to receive(:store_graph).and_return(true)
        stub_request(:get, 'http://ci-test:8080/bigdata/namespace/rw/sparql?GETSTMTS&includeInferred=false&s=%3Chttp://opaquenamespace.org/ns/creator/ChabreWayne%3E').with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Connection' => 'keep-alive', 'Host' => 'ci-test:8080', 'Keep-Alive' => '30', 'User-Agent' => 'Ruby' }).to_return(status: 200, body: '', headers: {})
        stub_request(:get, 'http://ci-test:8080/bigdata/namespace/rw/sparql?GETSTMTS&includeInferred=false&s=%3Chttp://opaquenamespace.org/ns/genus/Acnanthes%3E').to_return(status: 200, body: '', headers: {})
        stub_request(:get, 'http://opaquenamespace.org/ns/creator/ChabreWayne').to_return(status: 200, body: '', headers: {})
        stub_request(:get, 'https://opaquenamespace.org/ns/creator/ChabreWayne').to_return(status: 200, body: '', headers: {})
        stub_request(:get, 'http://opaquenamespace.org/ns/genus/Acnanthes').to_return(status: 200, body: '', headers: {})
      end

      it 'fetches all of its linked data labels' do
        expect(OregonDigital::Triplestore).to receive(:fetch).exactly(3).times
        expect(OregonDigital::Triplestore).to receive(:fetch_cached_term).once
        worker.perform(work.id, work.depositor)
      end
    end

    context 'when the request fails' do
      before do
        # TODO: ADD THIS BACK IN WHEN SETTING UP EMAILING FOR JOBS
        # allow(worker).to receive(:fetch_failed_callback).with(nil, creator_controlled_val).and_return(true)
        stub_request(:get, 'http://ci-test:8080/bigdata/namespace/rw/sparql?GETSTMTS&includeInferred=false&s=%3Chttp://opaquenamespace.org/ns/creator/ChabreWayne%3E').with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Connection' => 'keep-alive', 'Host' => 'ci-test:8080', 'Keep-Alive' => '30', 'User-Agent' => 'Ruby' }).to_return(status: 500, body: '', headers: {})
        stub_request(:get, 'http://ci-test:8080/bigdata/namespace/rw/sparql?GETSTMTS&includeInferred=false&s=%3Chttp://opaquenamespace.org/ns/genus/Acnanthes%3E').with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Connection' => 'keep-alive', 'Host' => 'ci-test:8080', 'Keep-Alive' => '30', 'User-Agent' => 'Ruby' }).to_return(status: 500, body: '', headers: {})
        stub_request(:get, 'http://opaquenamespace.org/ns/creator/ChabreWayne').to_return(status: 500, body: '', headers: {})
        stub_request(:get, 'https://opaquenamespace.org/ns/creator/ChabreWayne').to_return(status: 500, body: '', headers: {})
        stub_request(:get, 'http://opaquenamespace.org/ns/genus/Acnanthes').to_return(status: 500, body: '', headers: {})
        allow(location_controlled_val).to receive('fetch')
      end

      it 'calls #fetch_failed_graph to fire off new job' do
        expect(worker).to receive(:fetch_failed_graph).exactly(4).times
        worker.perform(work.id, work.depositor)
      end
    end
  end
end
