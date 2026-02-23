# frozen_string_literal: true

Rails.application.config.to_prepare do
  Hyrax::AttachFilesToWorkJob.class_eval do

    private
    # modify the call to FileSet.create with the work id, prefixed with "f" and the file index
    # Originally added to avoid collisions during migration; retaining as useful (until it isn't).
    def perform_af(work, uploaded_files, work_attributes)
      validate_files!(uploaded_files)
      depositor = proxy_or_depositor(work)
      user = User.find_by_user_key(depositor)

      work, work_permissions = create_permissions work, depositor
      @offset = 0
      @size = work.file_sets.size
      uploaded_files.each_with_index do |uploaded_file, i|
        next if uploaded_file.file_set_uri.present?
        attach_work(user, work, work_attributes, work_permissions, uploaded_file, i)
      end
    end

    def attach_work(user, work, work_attributes, work_permissions, uploaded_file, index)
      actor = Hyrax::Actors::FileSetActor.new(FileSet.new(id: pid(index, work)), user)
      file_set_attributes = file_set_attrs(work_attributes, uploaded_file)
      metadata = visibility_attributes(work_attributes, file_set_attributes)
      uploaded_file.add_file_set!(actor.file_set)
      actor.file_set.permissions_attributes = work_permissions
      actor.create_metadata(metadata)
      actor.create_content(uploaded_file)
      actor.attach_to_work(work, metadata)
    end

    def pid(index, work)
      (@offset..999).each do |i|
        trial_fnum = index + i + @size
        if usable? "f#{trial_fnum}#{work.id}"
          @offset = i
          return "f#{trial_fnum}#{work.id}"
        end
      end
    end

    # We need to be able to distinguish between a pid that results
    # in an ObjectNotFound and one that is tombstoned. Once use_valkyrie==true,
    # this may require a new query service that passes those errors through
    # rather than replacing with Valkyrie::Persistence::ObjectNotFoundError
    def usable?(id)
      fs = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: id, use_valkyrie: false)
      return false

    rescue Ldp::Gone
      return false

    rescue ActiveFedora::ObjectNotFoundError
      return true
    end
  end
end
