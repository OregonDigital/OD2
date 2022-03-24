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

  before do
    allow(creator_controlled_val).to receive(:fetch).with(:anything).and_return({})
    allow(subject_controlled_val).to receive(:fetch).with(:anything).and_return({})
    allow(location_controlled_val).to receive(:fetch).with(:anything).and_return({})
    allow(scientific_controlled_val).to receive(:fetch).with(:anything).and_return({})
    allow_any_instance_of(OregonDigital::ControlledVocabularies::Creator).to receive(:solrize).and_return(['http://opaquenamespace.org/ns/creator/ChabreWayne', { label: 'Chabre, Wayne$http://opaquenamespace.org/ns/creator/ChabreWayne' }])
    allow_any_instance_of(OregonDigital::ControlledVocabularies::Subject).to receive(:solrize).and_return(['http://opaquenamespace.org/ns/creator/ChabreWayne', { label: 'Chabre, Wayne$http://opaquenamespace.org/ns/creator/ChabreWayne' }])
    allow_any_instance_of(Hyrax::ControlledVocabularies::Location).to receive(:solrize).and_return(['http://opaquenamespace.org/ns/creator/ChabreWayne', { label: 'Chabre, Wayne$http://opaquenamespace.org/ns/creator/ChabreWayne' }])
    allow_any_instance_of(OregonDigital::ControlledVocabularies::Scientific).to receive(:solrize).and_return(['http://opaquenamespace.org/ns/genus/Acnanthes', { label: 'Acnanthes$http://opaquenamespace.org/ns/genus/Acnanthes' }])
  end

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

      it 'fetches a work and indexes its linked data labels' do
        worker.perform(work.id, work.depositor)
        expect(SolrDocument.find(work.id)['creator_label_tesim'].first).to eq 'Chabre, Wayne'
      end

      it 'indexes creator data into the creator_combined_label field' do
        worker.perform(work.id, work.depositor)
        expect(SolrDocument.find(work.id)['creator_combined_label_sim'].first).to eq 'Chabre, Wayne'
      end

      it 'indexes data into the location_combined_label field' do
        worker.perform(work.id, work.depositor)
        expect(SolrDocument.find(work.id)['location_combined_label_sim'].first).to eq 'Chabre, Wayne'
      end

      it 'indexes non-linked topic data into the creator_combined_label field' do
        worker.perform(work.id, work.depositor)
        expect(SolrDocument.find(work.id)['topic_combined_label_sim']).to include 'bar'
      end

      it 'indexes linked topic data into the topic_combined_label field' do
        worker.perform(work.id, work.depositor)
        expect(SolrDocument.find(work.id)['topic_combined_label_sim']).to include 'Chabre, Wayne'
      end

      it 'indexes data into the scientific_combined_label field' do
        worker.perform(work.id, work.depositor)
        expect(SolrDocument.find(work.id)['scientific_combined_label_sim'].first).to eq 'Acnanthes'
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
      end

      it 'calls #fetch_failed_graph to fire off new job' do
        expect(worker).to receive(:fetch_failed_graph).exactly(4).times
        worker.perform(work.id, work.depositor)
      end
    end
  end
end
