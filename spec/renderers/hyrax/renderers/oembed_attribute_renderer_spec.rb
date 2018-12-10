# frozen_string_literal:true

RSpec.describe Hyrax::Renderers::OembedAttributeRenderer do
  before do
    stub_request(:get, 'https://www.youtube.com/oembed?format=json&scheme=https&url=https://www.youtube.com/watch?v=8ZtInClXe1Q')
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Mozilla/5.0 (compatible; ruby-oembed/0.12.0)'
        }
      )
      .to_return(
        status: 200,
        body: '{"provider_name":"YouTube","thumbnail_height":360,"thumbnail_width":480,"type":"video","version":"1.0","provider_url":"https:\/\/www.youtube.com\/","title":"How NOT to Store Passwords! - Computerphile","html":"\u003ciframe width=\"480\" height=\"270\" src=\"https:\/\/www.youtube.com\/embed\/8ZtInClXe1Q?feature=oembed\" frameborder=\"0\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen\u003e\u003c\/iframe\u003e","height":270,"author_name":"Computerphile","thumbnail_url":"https:\/\/i.ytimg.com\/vi\/8ZtInClXe1Q\/hqdefault.jpg","width":480,"author_url":"https:\/\/www.youtube.com\/user\/Computerphile"}',
        headers: {
          'content-type' => 'application/json'
        }
      )
  end

  describe '#attribute_to_html' do
    subject { Nokogiri::HTML(rendered) }

    let(:rendered) { renderer.render }
    let(:expected) { Nokogiri::HTML(tr_content) }

    context 'with a value' do
      let(:renderer) { described_class.new(field, ['https://www.youtube.com/watch?v=8ZtInClXe1Q']) }
      let(:field) { :oembed_url }
      let(:tr_content) do
        '<tr><th>oEmbed</th>' \
         '<td><ul class=\'tabular\'><li class="attribute attribute-oembed_url">' \
         '<div class=\'oembed-widget\'>' \
         '<div data-embed-url="/oembed/embed?url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3D8ZtInClXe1Q">' \
         '</div></div></li></ul></td></tr>'
      end

      it { is_expected.to be_equivalent_to(expected) }
    end
  end
end
