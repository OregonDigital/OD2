# frozen_string_literal:true

RSpec.describe Hyrax::HomepageController, type: :controller do
  let(:user_collection_type) { create(:collection_type, machine_id: :user_collection) }
  let(:oai_collection_type) { create(:collection_type, machine_id: :oai_set) }

  routes { Hyrax::Engine.routes }

  describe '#index' do
    let(:user) { create(:user) }

    before do
      sign_in user
      allow(Hyrax::CollectionType).to receive(:find).with(machine_id: :user_collection).and_return(user_collection_type)
      allow(Hyrax::CollectionType).to receive(:find).with(machine_id: :oai_set).and_return(oai_collection_type)
    end

    context 'with existing featured researcher' do
      let!(:frodo) { ContentBlock.create!(name: ContentBlock::NAME_REGISTRY[:researcher], value: 'Frodo Baggins', created_at: Time.zone.now) }

      it 'finds the featured researcher' do
        get :index
        expect(response).to be_successful
        expect(assigns(:featured_researcher)).to eq frodo
      end
    end

    context 'with no featured researcher' do
      it 'creates a featured researcher' do
        get :index
        assigns(:featured_researcher).tap do |researcher|
          expect(researcher).to be_kind_of ContentBlock
        end
      end
      it 'sets featured researcher' do
        get :index
        expect(response).to be_successful
        assigns(:featured_researcher).tap do |researcher|
          expect(researcher).to be_kind_of ContentBlock
          expect(researcher.name).to eq 'featured_researcher'
        end
      end
    end

    it 'creates marketing text' do
      get :index
      assigns(:marketing_text).tap do |marketing|
        expect(marketing).to be_kind_of ContentBlock
      end
    end
    it 'sets marketing text' do
      get :index
      expect(response).to be_successful
      assigns(:marketing_text).tap do |marketing|
        expect(marketing).to be_kind_of ContentBlock
        expect(marketing.name).to eq 'marketing_text'
      end
    end

    it 'does not include other user\'s private documents in recent documents' do
      get :index
      expect(response).to be_successful
      titles = assigns(:recent_documents).map { |d| d['title_tesim'][0] }
      expect(titles).not_to include('Test Private Document')
    end

    it 'includes only Generic objects in recent documents' do
      get :index
      assigns(:recent_documents).each do |doc|
        expect(doc['has_model_ssim']).to eql ['Generic']
      end
    end

    context 'with a document not created this second', clean_repo: true do
      before do
        gw3 = Generic.new(title: ['Test 3 Document'], read_groups: ['public'])
        gw3.apply_depositor_metadata('mjg36')
        # stubbing to_solr so we know we have something that didn't create in the current second
        old_to_solr = gw3.method(:to_solr)
        allow(gw3).to receive(:to_solr) do
          old_to_solr.call.merge(
            'system_create_dtsi' => 1.day.ago.iso8601,
            'date_uploaded_dtsi' => 1.day.ago.iso8601
          )
        end
        gw3.save
      end

      it 'does not exceed the maximum recent documents' do
        get :index
        expect(assigns(:recent_documents).length).to be <= 6
      end
      it 'sets recent documents in the right order' do
        get :index
        expect(response).to be_successful
        expect(assigns(:recent_documents).length).to be <= 6
        create_times = assigns(:recent_documents).map { |d| d['date_uploaded_dtsi'] }
        expect(create_times).to eq create_times.sort.reverse
      end
    end

    context 'with collections' do
      let(:presenter) { double }
      let(:collection_results) { double(documents: ['collection results']) }

      before do
        allow(controller).to receive(:search_results).and_return([nil, ['recent document']])
        allow_any_instance_of(Hyrax::CollectionsService).to receive(:search_results).and_return(collection_results.documents)
      end

      it 'initializes the presenter with ability and a list of collections' do
        expect(Hyrax::HomepagePresenter).to receive(:new).with(Ability,
                                                               ['collection results'])
                                                         .and_return(presenter)
        get :index
      end
      it 'assigns the presenter' do
        allow(Hyrax::HomepagePresenter).to receive(:new).with(Ability,
                                                              ['collection results'])
                                                        .and_return(presenter)
        get :index
        expect(assigns(:presenter)).to eq presenter
      end
    end

    context 'with featured works' do
      let!(:my_work) { create(:work, user: user) }

      before do
        FeaturedWork.create!(work_id: my_work.id)
      end

      it 'sets featured works' do
        get :index
        expect(response).to be_successful
        expect(assigns(:featured_work_list)).to be_kind_of FeaturedWorkList
      end
    end

    it 'creates announcement content block' do
      get :index
      assigns(:announcement_text).tap do |announcement|
        expect(announcement).to be_kind_of ContentBlock
      end
    end
    it 'sets announcement content block' do
      get :index
      expect(response).to be_successful
      assigns(:announcement_text).tap do |announcement|
        expect(announcement).to be_kind_of ContentBlock
        expect(announcement.name).to eq 'announcement_text'
      end
    end

    context 'without solr' do
      before do
        allow_any_instance_of(Hyrax::SearchService).to receive(:search_results).and_raise Blacklight::Exceptions::InvalidRequest
      end

      it 'errors admin_sets gracefully' do
        get :index
        expect(assigns(:admin_sets)).to be_blank
      end
      it 'errors recent_documents gracefully' do
        get :index
        expect(assigns(:recent_documents)).to be_blank
      end
    end
  end
end
