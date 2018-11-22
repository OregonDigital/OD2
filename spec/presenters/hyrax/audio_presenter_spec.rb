# Generated via
#  `rails generate hyrax:work Audio`
require 'rails_helper'

RSpec.describe Hyrax::AudioPresenter do
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:ability) { double "Ability" }
  let(:presenter) { described_class.new(solr_document, ability) }

  let(:attributes) do
    { "id" => '888888',
      "title_tesim" => ['foo', 'bar'],
      "human_readable_type_tesim" => ["Generic Work"],
      "has_model_ssim" => ["Audio"],
      "date_created_tesim" => ['an unformatted date'],
      "depositor_tesim" => user.user_key }
  end

  let(:core_props) {[:title, :depositor, :date_uploaded, :date_modified]}
  let(:user) { double(user_key: 'generic person 1')}

  it "delegates the method to solr document" do
    core_props.each do |prop|
      expect(presenter).to delegate_method(prop).to(:solr_document)
    end
  end
end
