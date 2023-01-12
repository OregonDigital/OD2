# frozen_string_literal: true
require 'vcr'

namespace :oregon_digital do
  desc 'Create jobs to recreate text extraction and hOCR derivatives'
  task recreate_text_derivatives: :environment do
    FileSet.all.each do |file_set|
      next unless file_set.pdf?
      file_set.files.each do |file|
        next unless file_set.class.pdf_mime_types.include? file.mime_type

        filename = Hyrax::WorkingDirectory.find_or_retrieve(file.id, file_set.id)
        ReExtractTextWorker.perform_async(file_set.id, filename)
      end
    end
  end
end
