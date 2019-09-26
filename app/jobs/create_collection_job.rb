# frozen_string_literal: true

class CreateCollectionJob < ApplicationJob
  def perform(args)
    id = args[:id]
    collection = Collection.new(id: id, title: [args[:title]], visibility: args[:visibility], collection_type_gid: args[:collection_type_gid])
    Hyrax::PermissionTemplate.create!(source_id: args[:id])
    Rails.logger.info "Successfully created collection #{id}" if collection.save
  rescue StandardError => e
    Rails.logger.warn "Unable to create collection #{id}"
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
  end
end
