# frozen_string_literal: true

require 'valkyrie'
Rails.application.config.to_prepare do
  Valkyrie::MetadataAdapter.register(
    Valkyrie::Persistence::Postgres::MetadataAdapter.new,
    :postgres
  )

  Valkyrie::MetadataAdapter.register(
    Valkyrie::Persistence::Fedora::MetadataAdapter.new(connection: Ldp::Client.new(ENV.fetch('FEDORA_URL', 'http://localhost:8080/rest')),
                                                       base_path: 'development',
                                                       schema: Valkyrie::Persistence::Fedora::PermissiveSchema.new(hasModel: ActiveFedora::RDF::Fcrepo::Model.hasModel,
                                                                                                                   title: ::RDF::Vocab::DC.title)),
    :fedora
  )

  Valkyrie::MetadataAdapter.register(
    Valkyrie::Persistence::Memory::MetadataAdapter.new,
    :memory
  )

  Valkyrie::StorageAdapter.register(
    Valkyrie::Storage::Disk.new(base_path: Rails.root.join("tmp", "files")),
    :disk
  )

  Valkyrie::StorageAdapter.register(
    Valkyrie::Storage::Fedora.new(connection: Ldp::Client.new(ENV.fetch('FEDORA_URL', 'http://localhost:8080/rest'))),
    :fedora
  )

  Valkyrie::StorageAdapter.register(
    Valkyrie::Storage::Memory.new,
    :memory
  )
end
