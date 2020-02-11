# frozen_string_literal: true

RSpec.describe OregonDigital::Forms::CollectionForm do
  let(:collection) { build(:collection) }
  let(:ability) { Ability.new(create(:user)) }
  let(:repository) { double }
  let(:form) { described_class.new(collection, ability, repository) }
  let(:expected_terms) { %i[resource_type title creator contributor description license publisher date_created subject language representative_id thumbnail_id related_url visibility collection_type_gid institution date repository] }

  describe '#terms' do
    let(:terms) { described_class.terms }

    it do
      expect(terms).to eq expected_terms
    end
  end

  describe '#primary_terms' do
    let(:primary_terms) { form.primary_terms }

    it {
      expect(primary_terms).to eq(%i[title description
                                     creator contributor
                                     license publisher
                                     date_created subject
                                     language
                                     related_url resource_type
                                     institution date
                                     repository])
    }
  end

  describe '#secondary_terms' do
    let(:secondary_terms) { form.secondary_terms }

    it { expect(secondary_terms).to eq [] }
  end

  describe '#[]' do
    it 'has one element' do
      expect(form['description']).to eq ['']
    end
  end

  describe 'initialized fields' do
    context 'with :description' do
      let(:description) { form[:description] }

      it { expect(description).to eq [''] }
    end
  end
end
