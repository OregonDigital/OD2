# Generated via
#  `rails generate hyrax:work Generic`
require 'rails_helper'

RSpec.describe Hyrax::GenericPresenter do
  let(:solr_document) { SolrDocument.new(attributes) }
  let(:ability) { double "Ability" }
  let(:presenter) { described_class.new(solr_document, ability) }
  let(:attributes) { file.to_solr }
  let(:file) do
    Generic.new(
          id: '123abc',
          title: ['blah'],
          depositor: user.user_key,
          label: "filename.tif")
  end
  let(:props) {OregonDigital::GenericMetadata::PROPERTIES.map(&:to_sym)}
  let(:user) { double(user_key: 'generic person 1')}

  it "delegates the method to solr document" do
    props.each do |prop|
      expect(presenter).to delegate_method(prop).to(:solr_document)
    end
  end
end
