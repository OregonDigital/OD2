# frozen_string_literal: true

require 'rails_helper'

module OregonDigital
  RSpec.describe ExportBatchJob, type: :job do
    include ActiveJob::TestHelper
    subject(:export_batch_job) { described_class.new }

    let(:exporter) { create(:bulkrax_exporter) }
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

      after do
        clear_enqueued_jobs
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
      let(:entry2) { instance_double('Bulkrax::CsvEntry', id: 1, identifier: work.id) }
      let(:work) { instance_double('Generic', id: 'fxfx12345') }
      let(:parser) { instance_double('Bulkrax::CsvParser') }
      # ActiveFedora tries to find the work and can't, and so the entry fails
      # If the test stops working, it might be because ActiveFedora actually finds something.

      before do
        allow(exporter).to receive(:parser).and_return(parser)
        allow(parser).to receive(:find_or_create_entry).and_return(entry2)
      end

      it 'updates record counts' do
        count_failed = exporter_run.failed_records
        count_enqueued = exporter_run.enqueued_records
        export_batch_job.perform([[work.id, 'Bulkrax::CsvEntry']], exporter_run.id)
        exporter_run.reload
        expect(exporter_run.failed_records).to eq(count_failed + 1)
        expect(exporter_run.enqueued_records).to eq(count_enqueued - 1)
      end
    end
  end
end
