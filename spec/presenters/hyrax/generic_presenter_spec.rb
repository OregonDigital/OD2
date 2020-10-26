# frozen_string_literal:true

RSpec.describe Hyrax::GenericPresenter do
  let(:presenter) { described_class.new(solr_document, ability) }
  let(:presenters) { [] }
  let(:model) { build(:generic) }
  let(:ability) { instance_double('Ability') }
  let(:solr_document) { SolrDocument.new(model.attributes) }
  let(:props) { Generic.generic_properties.map(&:to_sym) }

  before do
    allow(presenter).to receive(:file_set_presenters).and_return(presenters)
  end

  it 'delegates the method to solr document' do
    props.each do |prop|
      expect(presenter).to delegate_method(prop).to(:solr_document)
    end
  end

  describe '#iiif_viewer?' do
    let(:presenters) do
      [
        instance_double('FileSetPresenter'),
        instance_double('FileSetPresenter'),
        instance_double('FileSetPresenter')
      ]
    end

    before do
      presenters.each do |p|
        allow(p).to receive(:image?).and_return false
        allow(p).to receive(:pdf?).and_return false
      end
    end

    context 'when an image presenter exists' do
      before do
        allow(presenters[1]).to receive(:image?).and_return true
        allow(presenters[1]).to receive(:id).and_return :image
      end

      it 'checks if the image can be read' do
        expect(ability).to receive(:can?).with(:read, :image)
        presenter.iiif_viewer?
      end

      it 'returns true if the image is readable' do
        allow(ability).to receive(:can?).with(:read, :image).and_return true
        expect(presenter.iiif_viewer?).to eq(true)
      end

      it 'returns false if the image is not readable' do
        allow(ability).to receive(:can?).with(:read, :image).and_return false
        expect(presenter.iiif_viewer?).to eq(false)
      end
    end

    context 'when a pdf presenter exists' do
      before do
        allow(presenters[1]).to receive(:pdf?).and_return true
        allow(presenters[1]).to receive(:id).and_return :pdf
      end

      it 'checks if the pdf can be read' do
        expect(ability).to receive(:can?).with(:read, :pdf)
        presenter.iiif_viewer?
      end

      it 'returns true if the pdf is readable' do
        allow(ability).to receive(:can?).with(:read, :pdf).and_return true
        expect(presenter.iiif_viewer?).to eq(true)
      end

      it 'returns false if the pdf is not readable' do
        allow(ability).to receive(:can?).with(:read, :pdf).and_return false
        expect(presenter.iiif_viewer?).to eq(false)
      end
    end

    context 'when none are images or pdfs' do
      it 'returns false' do
        expect(presenter.iiif_viewer?).to eq(false)
      end
    end
  end

  describe '#oembed_viewer?' do
    let(:presenters) do
      [
        instance_double('FileSetPresenter'),
        instance_double('FileSetPresenter'),
        instance_double('FileSetPresenter')
      ]
    end

    before do
      presenters.each do |p|
        allow(p).to receive(:oembed?).and_return false
      end
    end

    context 'when an oembed presenter exists' do
      before do
        allow(presenters[1]).to receive(:oembed?).and_return true
        allow(presenters[1]).to receive(:id).and_return :oembed
      end

      it 'checks if the oembed can be read' do
        expect(ability).to receive(:can?).with(:read, :oembed)
        presenter.oembed_viewer?
      end

      it 'returns true if the oembed is readable' do
        allow(ability).to receive(:can?).with(:read, :oembed).and_return true
        expect(presenter.oembed_viewer?).to eq(true)
      end

      it 'returns false if the oembed is not readable' do
        allow(ability).to receive(:can?).with(:read, :oembed).and_return false
        expect(presenter.oembed_viewer?).to eq(false)
      end
    end

    context 'when none are oembeds' do
      it 'returns false' do
        expect(presenter.oembed_viewer?).to eq(false)
      end
    end
  end
end
