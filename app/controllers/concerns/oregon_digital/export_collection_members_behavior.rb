# frozen_string_literal: true

module OregonDigital
  # methods allowing export of collection members as RDF
  module ExportCollectionMembersBehavior
    def export_members
      OregonDigital::ExportCollectionMembersJob.perform_later(coll_id: @collection.id, email: current_user.email)
      redirect_to collection_path(@collection.id), notice: 'Export job is enqueued.'
    end

    def download_members
      send_file(path)
    end

    def path
      File.join(OD2::Application.config.local_path, 'export_colls', "export_#{@collection.id}.zip")
    end
  end
end
