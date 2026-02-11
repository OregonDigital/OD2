# frozen_string_literal: true

RSpec.describe OregonDigital::Forms::CollectionForm do
  let(:collection) { build(:collection) }
  let(:ability) { Ability.new(create(:user)) }
  let(:repository) { double }
  let(:form) { described_class.new(collection, ability, repository) }
  let(:expected_terms) { %i[id title creator contributor description license publisher date_created subject language has_finding_aid representative_id thumbnail_id related_url visibility collection_type_gid institution date repository local_contexts content_alert mask_content accessibility_feature accessibility_summary] }

  describe '#terms' do
    let(:terms) { described_class.terms }

    it do
      expect(terms).to eq expected_terms
    end
  end

  describe '#primary_terms' do
    let(:primary_terms) { form.primary_terms }

    it {
      expect(primary_terms).to eq(%i[id title description
                                     creator contributor
                                     license publisher
                                     date_created subject
                                     language has_finding_aid
                                     related_url
                                     institution date
                                     repository local_contexts
                                     accessibility_feature
                                     accessibility_summary])
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
