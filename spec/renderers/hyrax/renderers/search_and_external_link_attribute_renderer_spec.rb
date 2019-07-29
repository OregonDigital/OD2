# frozen_string_literal:true

RSpec.describe Hyrax::Renderers::SearchAndExternalLinkAttributeRenderer do
  describe '#li_value' do
    subject { Nokogiri::HTML(rendered) }

    let(:rendered) { renderer.send(:li_value, value) }
    let(:expected) { Nokogiri::HTML(content) }

    context 'with linked options' do
      let(:renderer) { described_class.new(field, [value], links: { value => link }) }
      let(:field) { :creator }
      let(:value) { 'Last, First' }
      let(:link) { 'https://google.com' }
      let(:content) do
        '<a href="/catalog?locale=en&amp;q=Last%2C+First&amp;search_field=creator">' \
        'Last, First' \
        '</a><a aria-label="Open link in new window" class="btn" target="_blank" href="https://google.com">' \
        '<span class="glyphicon glyphicon-new-window"></span></a>'
      end

      it { is_expected.to be_equivalent_to(expected) }
    end

    context 'without linked options' do
      let(:renderer) { described_class.new(field, [value]) }
      let(:field) { :creator }
      let(:value) { 'Last, First' }
      let(:link) { 'https://google.com' }
      let(:content) do
        '<a href="/catalog?locale=en&amp;q=Last%2C+First&amp;search_field=creator">' \
        'Last, First'
      end

      it { is_expected.to be_equivalent_to(expected) }
    end
  end
end
