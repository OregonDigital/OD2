# frozen_string_literal:true

RSpec.describe OregonDigital::NonUserCollectionsSearchBuilder do
  let(:collection_type) { create(:collection_type, machine_id: :user_collection) }
  let(:context) { double }
  let(:search_builder) { described_class.new(context) }

  before do
    collection_type.save
  end

  describe '#show_only_collections_not_created_users' do
    subject { search_builder.show_only_collections_not_created_users({}).first }

    it { is_expected.to include "{!raw f=collection_type_gid_ssim}#{collection_type.gid}" }
  end
end
