# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShowPageAdminHelper do
  describe 'show_importer_link' do
    context 'when there is a valid importer_id' do
      let(:solr_doc) { SolrDocument.new(attributes) }
      let(:attributes) do
        {
          'title' => ['everything is somewhere, at one time or another'],
          'bulkrax_identifier_tesim' => ['123-0'],
          'bulkrax_importer_id_sim' => ['123']
        }
      end

      before do
        allow(Bulkrax::Importer).to receive(:exists?).and_return(true)
      end

      # rubocop:disable Style/StringLiterals
      it 'returns the link' do
        expect(helper.show_importer_link(solr_doc, 'http://blah.org')).to eq("<a target=\"_blank\" href=\"http://blah.org/importers/123\">123-0</a>")
      end
      # rubocop:enable Style/StringLiterals
    end

    context 'when importer no longer exists' do
      let(:solr_doc) { SolrDocument.new(attributes) }
      let(:attributes) do
        {
          'title' => ['everything is out of whack, all at the same time'],
          'bulkrax_identifier_tesim' => ['123-0'],
          'bulkrax_importer_id_sim' => ['123']
        }
      end

      before do
        allow(Bulkrax::Importer).to receive(:exists?).and_return(false)
      end

      it 'returns the bulkrax identifier only' do
        expect(helper.show_importer_link(solr_doc, 'http://blah.org')).to eq('123-0: not found')
      end
    end

    context 'when there is no bulkrax identifier' do
      let(:solr_doc) { SolrDocument.new(attributes) }
      let(:attributes) do
        {
          'title' => ['something is everywhere, at once upon a time']
        }
      end

      it 'returns not found' do
        expect(helper.show_importer_link(solr_doc, 'http://blah.org')).to eq('not found')
      end
    end
  end
end
