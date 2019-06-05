# frozen_string_literal: true

# Dummy object implementing the required methods for the behavior mixin to work
class DummyHelper < ApplicationController
  include Blacklight::CatalogHelperBehavior
  include OregonDigital::ConfigurationHelperBehavior
end

RSpec.describe OregonDigital::ConfigurationHelperBehavior do
  let(:helper) { DummyHelper.new }
  let(:blacklight_config) { Blacklight::Configuration.new }

  describe '#facet_field_label' do
    let(:facet_field) { Blacklight::Configuration::FacetField.new(label: 'my_label') }

    it 'sets the first default to an i18n symbol if the field has not configured a label' do
      expect(helper).to receive(:field_label).with(:"blacklight.search.fields.facet.my_field", any_args)
      helper.facet_field_label('my_field')
    end

    it 'sets the first default to the configured label' do
      allow(helper).to receive(:blacklight_config).and_return(blacklight_config)
      blacklight_config.facet_fields['my_field'] = facet_field

      expect(helper).to receive(:field_label).with('my_label', any_args)
      helper.facet_field_label('my_field')
    end
  end

  describe '#field_label' do
    it 'looks up the label as an i18n string if the first option is a symbol' do
      expect(helper).to receive(:t).with(:some_key, default: [])
      helper.field_label :some_key
    end

    it 'defaults to the given string if a symbol is not given to look up' do
      expect(helper).not_to receive(:t)
      helper.field_label 'my label'
    end
  end
end
