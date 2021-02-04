# frozen_string_literal: true

RSpec.describe OregonDigital::InstitutionPicker do
  let(:picker) { described_class }
  let(:collection) { ::Collection.new }
  let(:osu_array) { ['http://id.loc.gov/authorities/names/n80017721'] }
  let(:uo_array) { ['http://id.loc.gov/authorities/names/n80126183'] }
  let(:junk_array) { ['blah', 1] }
  let(:both_array) { ['http://id.loc.gov/authorities/names/n80126183', 'http://id.loc.gov/authorities/names/n80017721'] }

  describe '#institution_acronym' do
    context 'when osu array is present' do
      before do
        allow(collection).to receive(:institution).and_return(osu_array)
      end

      it 'returns OSU' do
        expect(picker.institution_acronym(collection)).to eq 'OSU'
      end
    end

    context 'when uo array is present' do
      before do
        allow(collection).to receive(:institution).and_return(uo_array)
      end

      it 'returns UO' do
        expect(picker.institution_acronym(collection)).to eq 'UO'
      end
    end

    context 'when both osu and uo array is present' do
      before do
        allow(collection).to receive(:institution).and_return(both_array)
      end

      it 'returns the first one' do
        expect(picker.institution_acronym(collection)).to eq 'UO'
      end
    end

    context 'when junk is present' do
      before do
        allow(collection).to receive(:institution).and_return(junk_array)
      end

      it 'returns an empty string' do
        expect(picker.institution_acronym(collection)).to eq ''
      end
    end
  end

  describe '#institution_full_name' do
    context 'when osu array is present' do
      before do
        allow(collection).to receive(:institution).and_return(osu_array)
      end

      it 'returns Oregon State University' do
        expect(picker.institution_full_name(collection)).to eq 'Oregon State University'
      end
    end

    context 'when uo array is present' do
      before do
        allow(collection).to receive(:institution).and_return(uo_array)
      end

      it 'returns University of Oregon' do
        expect(picker.institution_full_name(collection)).to eq 'University of Oregon'
      end
    end

    context 'when both osu and uo array is present' do
      before do
        allow(collection).to receive(:institution).and_return(both_array)
      end

      it 'returns the first one' do
        expect(picker.institution_full_name(collection)).to eq 'University of Oregon'
      end
    end

    context 'when junk is present' do
      before do
        allow(collection).to receive(:institution).and_return(junk_array)
      end

      it 'returns an empty string' do
        expect(picker.institution_full_name(collection)).to eq ''
      end
    end
  end
end
