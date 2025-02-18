# frozen_string_literal:true

RSpec.describe Hyrax::GenericsController do
  describe '#attributes_for_actor' do
    let(:url) { 'http://test.com' }

    context 'when an oembed_url is set in the params' do
      it 'adds the url to the actor environment' do
        controller.params = ActionController::Parameters.new({ oembed_urls: [url] })
        expect(controller.attributes_for_actor[:oembed_urls]).to eq [url]
      end
    end
  end

  describe 'work relation pagination behavior' do
    let(:parent) { create(:work_with_ten_children) }

    context 'when all the children are viewable' do
      it 'displays children in order' do
        get :show, params: { id: parent.id, child_page: 1 }
        expect(assigns(:child_doc_list).map { |x| x['id'] }).to eq(parent.ordered_member_ids.slice(0, 4))
      end
      it 'displays all the children' do
        get :show, params: { id: parent.id, child_page: 3 }
        expect(assigns(:child_doc_list).map { |x| x['id'] }).to eq(parent.ordered_member_ids.slice(8, 2))
      end
    end

    context 'when some of the children are viewable' do
      before do
        ids = parent.ordered_member_ids
        ch4 = Generic.find(ids[4])
        ch4.visibility = 'restricted'
        ch4.save
        ch5 = Generic.find(ids[5])
        ch5.visibility = 'restricted'
        ch5.save
      end

      it 'displays the viewable children' do
        get :show, params: { id: parent.id, child_page: 3 }
        expect(assigns(:child_doc_list).map { |x| x['id'] }).to eq(parent.ordered_member_ids.slice(8, 2))
      end

      it 'skips the restricted children' do
        get :show, params: { id: parent.id, child_page: 2 }
        expect(assigns(:child_doc_list).map { |x| x['id'] }).to eq(parent.ordered_member_ids.slice(6, 2))
      end
    end
  end
end
