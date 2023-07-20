# frozen_string_literal:true

RSpec.describe OregonDigital::IiifV2Presenter do
  let(:document) { SolrDocument.new }
  let(:ability) { instance_double('Ability') }
  let(:presenter) { described_class.new(document, ability, nil) }

  describe '#file_set_presenters' do
    let(:fs1) { FileSet.new(id: 'fileset1', label: 'fs1') }
    let(:fs2) { FileSet.new(id: 'fileset2', label: 'fs2') }
    let(:fs3) { FileSet.new(id: 'fileset3', label: 'fs3') }
    let(:fs4) { FileSet.new(id: 'fileset4', label: 'fs4') }
    let(:fsderivs1) { instance_double('OregonDigital::FileSetDerivativesService') }
    let(:fsderivs2) { instance_double('OregonDigital::FileSetDerivativesService') }
    let(:fsderivs3) { instance_double('OregonDigital::FileSetDerivativesService') }
    let(:fsderivs4) { instance_double('OregonDigital::FileSetDerivativesService') }

    before do
      allow(ability).to receive(:can?).and_return true
      presenter.file_sets = [fs1, fs2, fs3, fs4]
      allow(fs1).to receive(:image?).and_return(true)
      allow(fs2).to receive(:image?).and_return(true)
      allow(fs3).to receive(:image?).and_return(true)
      allow(fs4).to receive(:image?).and_return(true)
      allow(fs1.parents.first).to receive(:title_or_label).and_return('fs1')
      allow(fs2.parents.first).to receive(:title_or_label).and_return('fs2')
      allow(fs3.parents.first).to receive(:title_or_label).and_return('fs3')
      allow(fs4.parents.first).to receive(:title_or_label).and_return('fs4')
      allow(presenter).to receive(:file_set_derivatives_service).with(fs1).and_return(fsderivs1)
      allow(presenter).to receive(:file_set_derivatives_service).with(fs2).and_return(fsderivs2)
      allow(presenter).to receive(:file_set_derivatives_service).with(fs3).and_return(fsderivs3)
      allow(presenter).to receive(:file_set_derivatives_service).with(fs4).and_return(fsderivs4)
      allow(fsderivs1).to receive(:sorted_derivative_urls).with('jp2').and_return(%w[one another])
      allow(fsderivs2).to receive(:sorted_derivative_urls).with('jp2').and_return([])
      allow(fsderivs3).to receive(:sorted_derivative_urls).with('jp2').and_return(['third'])
      allow(fsderivs4).to receive(:sorted_derivative_urls).with('jp2').and_return(%w[4 andfive])
    end

    it 'returns one presenter for each JP2 for each fileset' do
      expect(presenter.file_set_presenters.length).to eq(5)
    end

    it "returns the expected JP2s' presenters" do
      expect(presenter.file_set_presenters.collect(&:jp2_path)).to eq(%w[one another third 4 andfive])
    end
  end

  describe '#page_label' do
    it 'includes the asset label and page label for the first page' do
      expect(presenter.send(:page_label, 'Foo', 0)).to eq('1')
    end

    it "doesn't include the asset label after the first page" do
      expect(presenter.send(:page_label, 'Foo', 1)).to eq('2')
    end
  end
end
