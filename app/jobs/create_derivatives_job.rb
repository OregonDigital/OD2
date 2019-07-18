# frozen_string_literal:true

# Turns a derivatives job into an out-of-band job to generate derivative files
# and send them to S3.  The rest of the derivative creation logic, from Hyrax's
# CreateDerivativesJob, is in the UpdateFilesetJob, which is queued up once the
# external job completes.
class CreateDerivativesJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  def perform(file_set, file_id, filepath = nil)
    filename = Hyrax::WorkingDirectory.find_or_retrieve(file_id, file_set.id, filepath)

    # This is really stupid, but rubocop actually sees this alias as being
    # significantly simpler than just having "file_set.class" in the lines
    # below
    fsc = file_set.class

    case file_set.mime_type
    when *fsc.pdf_mime_types             then queue('CreatePDFDerivativesJob', file_set, filename)
    when *fsc.office_document_mime_types then queue('CreateOfficeDocumentDerivativesJob', file_set, filename)
    when *fsc.audio_mime_types           then queue('CreateAudioDerivativesJob', file_set, filename)
    when *fsc.video_mime_types           then queue('CreateVideoDerivativesJob', file_set, filename)
    when *fsc.image_mime_types           then queue('CreateImageDerivativesJob', file_set, filename)
    end
  end

  def queue(class_name, file_set, filename)
    Sidekiq::Client.new.push(
      'queue' => 'derivatives',
      'class' => class_name,
      'args' => [file_set.id, filename, file_set.mime_type]
    )
  end
end
