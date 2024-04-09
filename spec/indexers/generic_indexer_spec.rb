# frozen_string_literal:true

RSpec.describe GenericIndexer do
  let(:indexer) { described_class.new(work) }
  let(:solr_doc) { indexer.generate_solr_document }
  let(:work) { create(:generic, license: ['http://creativecommons.org/licenses/by/4.0/'], rights_statement: ['http://rightsstatements.org/vocab/InC/1.0/'], language: ['http://id.loc.gov/vocabulary/iso639-2/eng'], resource_type: 'http://purl.org/dc/dcmitype/Collection') }

  it { expect(solr_doc['resource_type_label_tesim']).to eq 'Complex Object' }
  it { expect(solr_doc['license_label_tesim']).to eq ['Creative Commons BY Attribution 4.0 International'] }
  it { expect(solr_doc['language__label_tesim']).to eq ['English [eng]'] }
  it { expect(solr_doc['rights_statement_label_tesim']).to eq ['In Copyright'] }

  describe 'date facet yearly' do
    let(:field) { solr_doc['date_combined_year_label_ssim'] }

    context 'when given date is empty' do
      before { work.date_created = [] }

      it 'returns an empty array' do
        expect(field).to eq []
      end
    end

    context 'when given an invalid date' do
      before { work.date_created = ['typo2011-01-01'] }

      it 'returns an empty array' do
        expect(field).to eq []
      end
    end

    context 'when given a date' do
      before { work.date_created = ['2022-01-01'] }

      it 'returns an that year' do
        expect(field).to eq [2022]
      end
    end

    context 'when given just a year' do
      before { work.date_created = ['2011'] }

      it 'returns the year' do
        expect(field).to eq [2011]
      end
    end

    context 'when given a range of dates YYYY-mm-dd/YYY-mm-dd' do
      before { work.date_created = ['1925-12-01/1927-01-01'] }

      it 'returns years in that range' do
        expect(field).to eq [1925, 1926, 1927]
      end
    end

    context 'when given a range of years only YYYY/YYYY' do
      before { work.date_created = ['2014/2017'] }

      it 'returns years in that range' do
        expect(field).to eq [2014, 2015, 2016, 2017]
      end
    end

    context 'when given a range of year and month only YYYY-mm/YYY-mm' do
      before { work.date_created = ['2017-12/2018-01'] }

      it 'returns years in that range' do
        expect(field).to eq [2017, 2018]
      end
    end
  end

  describe 'decade facets' do
    let(:field) { solr_doc['date_combined_decade_label_ssim'] }

    context 'when given date is empty' do
      before { work.date_created = [] }

      it 'returns an empty array' do
        expect(field).to eq []
      end
    end

    context 'when given a date' do
      before { work.date_created = ['2022-01-01'] }

      it 'returns that decade' do
        expect(field).to eq ['2020-2029']
      end
    end

    context 'when given just a year' do
      before { work.date_created = ['2011'] }

      it 'returns that decade' do
        expect(field).to eq ['2010-2019']
      end
    end

    context 'when given a date range in a single decade' do
      before { work.date_created = ['1910-1915'] }

      it 'returns only one entry' do
        expect(field).to eq ['1910-1919']
      end
    end

    context 'when given a date range which spans decades' do
      before { work.date_created = ['1910-1920'] }

      it 'returns two entries' do
        expect(field).to eq %w[1910-1919 1920-1929]
      end
    end

    context 'when given a date range which spans more than 30 years' do
      before { work.date_created = ['1900-1940'] }

      it 'returns an empty array' do
        expect(field).to eq []
      end
    end
  end
end
