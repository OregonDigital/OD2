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
end
