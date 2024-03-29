# frozen_string_literal:true

RSpec.describe ::SearchAndExternalLinkAttributeRenderer do
  describe '#li_value' do
    subject { Nokogiri::HTML(rendered) }

    let(:rendered) { renderer.send(:li_value, value) }
    let(:expected) { Nokogiri::HTML(content) }

    context 'with linked options' do
      let(:renderer) { described_class.new(field, [value], { links: { value => link }, indices: { link => 0 } }) }
      let(:field) { :creator }
      let(:value) { 'Last, First' }
      let(:link) { 'https://google.com' }
      let(:content) do
        '<a href="/catalog?f%5Bcreator_sim%5D%5B%5D=Last%2C+First&amp;locale=en">' \
        'Last, First' \
        '</a><a aria-label="learn more about this taxonomy term" class="metadata-superscript" title="learn more" href="#data_sources">' \
        '<sup>0</sup></a>'
      end

      it { is_expected.to be_equivalent_to(expected) }
    end

    context 'without linked options' do
      let(:renderer) { described_class.new(field, [value]) }
      let(:field) { :creator }
      let(:value) { 'Last, First' }
      let(:link) { 'https://google.com' }
      let(:content) do
        '<a href="/catalog?f%5Bcreator_sim%5D%5B%5D=Last%2C+First&amp;locale=en">' \
        'Last, First'
      end

      it { is_expected.to be_equivalent_to(expected) }
    end
  end
end
