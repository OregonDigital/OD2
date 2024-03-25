# frozen_string_literal:true

RSpec.describe GenericIndexer do
  let(:indexer) { described_class.new(work) }
  let(:solr_doc) { indexer.generate_solr_document }
  let(:work) { create(:generic, license: ['MyLicense'], rights_statement: ['MyRights'], language: ['MyLanguage'], resource_type: 'http://purl.org/dc/dcmitype/Collection') }

  before do
    allow(solr_doc).to receive(solr_doc['rights_statement_parasable_label_ssim']).with([]).and_return([])
    allow(solr_doc).to receive(solr_doc['license_parasable_label_ssim']).with([]).and_return([])
    allow(solr_doc).to receive(solr_doc['resource_type_parasable_label_ssim']).with('').and_return('')
    allow(solr_doc).to receive(solr_doc['language_parasable_label_ssim']).with([]).and_return([])
  end

  it { expect(solr_doc['resource_type_label_tesim']).to eq 'Complex Object' }
  it { expect(solr_doc['license_tesim']).to eq ['MyLicense'] }
  it { expect(solr_doc['language_tesim']).to eq ['MyLanguage'] }
  it { expect(solr_doc['rights_statement_tesim']).to eq ['MyRights'] }

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
