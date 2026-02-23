# frozen_string_literal:true

require 'rails_helper'

RSpec.describe FileSet, type: :model do
  subject { model }

  let(:model) { build(:file_set) }
  let(:url) { 'http://test.com' }

  describe 'oembed_metadata' do
    it 'accepts oembed_url metadata' do
      expect(model).to respond_to(:oembed_url)
    end
  end

  describe 'accessibility_metadata' do
    it 'accepts accessibility_feature metadata' do
      expect(model).to respond_to(:accessibility_feature)
    end
  end

  describe 'oembed?' do
    it 'returns false when an oembed_url is not present' do
      expect(model.oembed?).to be false
    end

    it 'returns true when an oembed_url is present' do
      model.oembed_url = url
      expect(model.oembed?).to be true
    end
  end
end
