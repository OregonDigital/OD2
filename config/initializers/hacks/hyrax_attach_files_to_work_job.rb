# frozen_string_literal: true

Rails.application.config.to_prepare do
  Hyrax::AttachFilesToWorkJob.class_eval do

    private
    # modify the call to FileSet.create with the work id, prefixed with "f" and the file index
    # to avoid collisions during migration. This can be removed once migration is complete
    def perform_af(work, uploaded_files, work_attributes)
      validate_files!(uploaded_files)
      depositor = proxy_or_depositor(work)
      user = User.find_by_user_key(depositor)

      work, work_permissions = create_permissions work, depositor
      metadata = visibility_attributes(work_attributes)
      uploaded_files.each_with_index do |uploaded_file, i|
        next if uploaded_file.file_set_uri.present?

        pid = "f#{(i+offset_index(work)).to_s}#{work.id}"
        actor = Hyrax::Actors::FileSetActor.new(FileSet.create(id: pid), user)
        uploaded_file.add_file_set!(actor.file_set)
        actor.file_set.permissions_attributes = work_permissions
        actor.create_metadata(metadata)
        actor.create_content(uploaded_file)
        actor.attach_to_work(work)
      end
    end

    def offset_index(work)
      work.file_sets.size
    end
  end
end
