# frozen_string_literal: true

module OregonDigital
  # Export properties needed for creating new digital objects in ArchivesSpace.
  module AspaceDigitalObjectExportBehavior
    def export_do
      OregonDigital::AspaceDigitalObjectExportJob.perform_later(importer_id: params['importer_id'], email: current_user.email)
      redirect_to importer_path(params['importer_id']), notice: 'Export job is enqueued.'
    end

    def download_do
      send_file(path(params['importer_id']))
    end

    def path(id)
      name = Bulkrax::Importer.find(id).name
      File.join(OD2::Application.config.local_path, 'export_do', "export_#{name}_do.zip")
    end
  end
end
