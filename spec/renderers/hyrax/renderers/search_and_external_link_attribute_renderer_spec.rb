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
        '<a href="/catalog?f%5Bcreator_sim%5D%5B%5D=Last%2C+First&amp;locale=en">' \
        'Last, First' \
        '</a><a aria-label="Open link in new window" class="btn" target="_blank" title="learn more" href="https://google.com">' \
        '<i class="fa fa-info-circle"></i><span class="sr-only">learn more</span></a>'
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
