namespace :oregon_digital do
  desc "Enqueue a job to resolrize repository objects in chunks"
  task :reindex_by_chunk, [:chunk_size] => :environment do |t, args|
    # Set a default value of 100 for chunk_size
    args.with_defaults(:chunk_size => 100)
    # Fetch all Fedora URIs
    fetcher = ActiveFedora::Base::DescendantFetcher.new(ActiveFedora.fedora.base_uri, exclude_self: true)
    descendants = fetcher.descendant_and_self_uris

    descendants.each_slice(args.chunk_size) do |uris|
      ReindexChunkWorker.perform_async(uris)
    end
  end
end