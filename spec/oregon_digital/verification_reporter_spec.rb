# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OregonDigital::VerificationReporter do
  let(:reporter) { described_class.new('mybatch', '202504040900') }
  let(:work) { double }

  describe '#compile_errors' do
    context 'when the work exists' do
      before do
        reporter.work_ids = ['abcde1234']
        allow(Hyrax.query_service).to receive(:find_by_alternate_identifier).and_return(work)
        allow(work).to receive(:all_errors).and_return({ dessert: ['no chocolate'] })
      end

      it 'returns a hash of errors' do
        expect(reporter.compile_errors).to eq([{ 'abcde1234' => { dessert: ['no chocolate'] } }])
      end
    end

    context 'when the work does not exist in valkyrie' do
      before do
        reporter.work_ids = ['abcde1234']
        allow(Hyrax.query_service).to receive(:find_by_alternate_identifier).and_raise(Valkyrie::Persistence::ObjectNotFoundError)
      end

      it 'returns a hash with correct error' do
        expect(reporter.compile_errors).to eq([{ 'abcde1234' => { valkyrie: ['Unable to load work.'] } }])
      end
    end
  end
end
