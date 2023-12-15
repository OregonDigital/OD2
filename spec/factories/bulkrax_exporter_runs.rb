# frozen_string_literal: true

FactoryBot.define do
  factory :bulkrax_exporter_run, class: 'Bulkrax::ExporterRun' do
    exporter { FactoryBot.build(:bulkrax_exporter) }
    total_work_entries { 1 }
    enqueued_records { 1 }
    processed_records { 0 }
    deleted_records { 0 }
    failed_records { 0 }
  end
end
