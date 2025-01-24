# frozen_string_literal:true

RSpec.describe OregonDigital::NonUserCollectionsSearchBuilder do
  let(:user_collection_type) { create(:collection_type, machine_id: :user_collection) }
  let(:oai_collection_type) { create(:collection_type, machine_id: :oai_set) }
  let(:context) { double }
  let(:search_builder) { described_class.new(context) }

  before do
    user_collection_type.save
    oai_collection_type.save
    allow(search_builder).to receive(:blacklight_config)
  end

  describe '#show_only_collections_not_created_users' do
    subject { search_builder.show_only_collections_not_created_users({}).first }

    it { is_expected.to include "{!raw f=collection_type_gid_ssim}#{user_collection_type.gid}" }
    it { is_expected.to include "{!raw f=collection_type_gid_ssim}#{oai_collection_type.gid}" }
  end
end
