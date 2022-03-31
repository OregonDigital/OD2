# frozen_string_literal: true

RSpec.describe OregonDigital::CollectionPresenter do
  let(:collection) do
    build(:collection,
          id: 'adc12v',
          description: ['a nice collection'],
          title: ['A clever title'],
          resource_type: 'Collection',
          related_url: ['http://example.com/'],
          date_created: ['some date'])
  end
  let(:ability) { double }
  let(:presenter) { described_class.new(solr_doc, ability) }
  let(:solr_doc) { SolrDocument.new(collection.to_solr) }

  before { allow(collection).to receive(:bytes).and_return(0) }

  describe '.terms' do
    let(:terms) { described_class.terms }

    it do
      expect(terms).to eq %i[total_items size resource_type creator_label contributor_label license publisher_label
                             date_created subject_label language related_url institution_label date repository_label]
    end
  end

  describe '#representative_docs' do
    let(:representative) { build(:collection_representative,
                                  collection_id: collection.id,
                                  fileset_id: solr_doc.id) }
    before { allow(::CollectionRepresentative).to receive(:where).with(collection_id: representative.collection_id).and_return(representative) }
    before { allow(::SolrDocument).to receive(:find).with(solr_doc.id).and_return(solr_doc) }
    it 'returns solr docs for fileset_id' do
      expect(presenter.representative_docs).to eq([solr_doc])
    end
  end

  # Mock bytes so collection does not have to be saved.

  describe 'collection type methods' do
    let(:props) do
      %i[title description creator contributor subject publisher language embargo_release_date
         lease_expiration_date license date_created resource_type related_url thumbnail_path
         title_or_label collection_type_gid create_date modified_date visibility edit_groups edit_people
         institution date repository]
    end

    it do
      props.each do |prop|
        expect(presenter).to delegate_method(prop).to(:solr_document)
      end
    end
  end
end
