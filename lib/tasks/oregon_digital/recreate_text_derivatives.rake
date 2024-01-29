# frozen_string_literal: true

namespace :oregon_digital do
  desc 'Create jobs to recreate text extraction and hOCR derivatives'
  task recreate_text_derivatives: :environment do
    Hyrax.query_service.find_all_of_model(model: Hyrax::FileSet).each do |file_set|
      next unless file_set.pdf?
      Hyrax.query_service.custom_queries.find_files(file_set: file_set).each do |file|
        next unless FileSet.pdf_mime_types.include? file.mime_type

        filename = Hyrax::WorkingDirectory.find_or_retrieve(file.id, file_set.id)
        ReExtractTextWorker.perform_async(file_set.id, filename)
      end
    end
  end
end
