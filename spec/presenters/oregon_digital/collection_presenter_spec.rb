RSpec.describe OregonDigital::CollectionPresenter do
  describe ".terms" do
    let(:terms) { described_class.terms }

    it do
      expect(terms).to eq [:total_items, :size, :resource_type, :creator, :contributor, :license, :publisher, 
                           :date_created, :subject, :language, :identifier, :related_url, :institution, :date, :repository]
    end
  end

  let(:collection) do
    build(:collection_lw,
          id: 'adc12v',
          description: ['a nice collection'],
          title: ['A clever title'],
          resource_type: ['Collection'],
          related_url: ['http://example.com/'],
          date_created: ['some date'])
  end
  let(:ability) { double }
  let(:presenter) { described_class.new(solr_doc, ability) }
  let(:solr_doc) { SolrDocument.new(collection.to_solr) }

  # Mock bytes so collection does not have to be saved.
  before { allow(collection).to receive(:bytes).and_return(0) }

  describe "collection type methods" do
    let(:props) {[:title, :description, :creator, :contributor, :subject, :publisher, :language, :embargo_release_date,
                  :lease_expiration_date, :license, :date_created, :resource_type, :related_url, :identifier, :thumbnail_path,
                  :title_or_label, :collection_type_gid, :create_date, :modified_date, :visibility, :edit_groups, :edit_people,
                  :institution, :date, :repository]}
    it do
      props.each do |prop|
        expect(presenter).to delegate_method(prop).to(:solr_document)
      end
    end
  end
end