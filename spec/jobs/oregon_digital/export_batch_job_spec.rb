# frozen_string_literal: true

require 'rails_helper'

module OregonDigital
  RSpec.describe ExportBatchJob, type: :job do
    subject(:export_batch_job) { described_class.new }

    let(:exporter) { create(:bulkrax_exporter) }
    let(:entry) { create(:bulkrax_csv_entry_export, identifier: work.id) }
    let(:exporter_run) { create(:bulkrax_exporter_run, exporter: exporter) }
    let(:work) { create(:generic) }

    describe 'success' do
      it 'increments :processed_records' do
        count = exporter_run.processed_records
        export_batch_job.perform([[work.id, 'Bulkrax::CsvEntry']], exporter_run.id)
        exporter_run.reload
        expect(exporter_run.processed_records).to eq(count + 1)
      end

      it 'decrements :enqueued_records' do
        count = exporter_run.enqueued_records
        export_batch_job.perform([[work.id, 'Bulkrax::CsvEntry']], exporter_run.id)
        exporter_run.reload
        expect(exporter_run.enqueued_records).to eq(count - 1)
      end
    end

    describe 'wrap_up' do
      before do
        ActiveJob::Base.queue_adapter = :test
      end

      it 'sets the status' do
        export_batch_job.perform([[work.id, 'Bulkrax::CsvEntry']], exporter_run.id)
        exporter_run.reload
        expect(exporter_run.exporter.status).to eq 'Complete'
      end

      it 'enqueues a write job' do
        export_batch_job.perform([[work.id, 'Bulkrax::CsvEntry']], exporter_run.id)
        exporter_run.reload
        expect(OregonDigital::ExporterWriteJob).to have_been_enqueued.exactly(1).times
      end
    end

    describe 'failed' do
      let(:error) { StandardError }
      let(:entry) { instance_double('Bulkrax::CsvEntry', id: 1, identifier: 'abcde1234') }
      let(:work) { instance_double('Generic', id: 'abcde1234') }
      let(:result) { double }

      before do
        allow(Bulkrax::CsvEntry).to receive(:where).and_return(result)
        allow(result).to receive(:first_or_create!).and_return(entry)
        allow(entry).to receive(:raw_metadata=)
        allow(entry).to receive(:save!)
        allow(entry).to receive(:build).and_raise(error)
      end

      it 'increments :failed_records' do
        count = exporter_run.failed_records
        export_batch_job.perform([[work.id, 'Bulkrax::CsvEntry']], exporter_run.id)
        exporter_run.reload
        expect(exporter_run.failed_records).to eq(count + 1)
      end

      it 'decrements :enqueued_records' do
        count = exporter_run.enqueued_records
        export_batch_job.perform([[work.id, 'Bulkrax::CsvEntry']], exporter_run.id)
        exporter_run.reload
        expect(exporter_run.enqueued_records).to eq(count - 1)
      end
    end
  end
end
