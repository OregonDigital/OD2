# frozen_string_literal:true

describe 'BlacklightAdvancedSearchForm' do
  describe 'advanced search form' do
    before do
      Hyrax::CollectionType.new(machine_id: 'user_collection', title: 'User Collection').save
      Hyrax::CollectionType.new(machine_id: 'oai_set', title: 'OAI Set').save
      visit '/advanced'
    end

    it 'has breadcrumbs' do
      expect(page.find(:xpath, "//nav[@class='breadcrumb col-sm-12']/ol/li[2]/a[@href='advanced']")).to be_visible
    end
  end
end
