# frozen_string_literal: true

# ReindexWorker is an extremely basic worker for reindexing a single asset,
# meant to be used in batch reindex operations as a way to ensure one asset's
# failure to reindex doesn't stop the rest of the assets' reindex processes.
class ReindexWorker
  include Sidekiq::Worker

  # pids must be ordered with access control objects first, then the actual
  # asset, then its sub-objects (a.g., proxies, indirect containers, etc.)
  def perform(access_control_pids, asset_pid, contains_pids)
    access_control_pids.each do |pid|
      obj = ActiveFedora::Base.find(pid)
      obj.permissions.each(&:update_index)
      obj.update_index
    end

    a = ActiveFedora::Base.find(asset_pid)

    pout =  "/data/tmp/reindex-#{a.class}-#{asset_pid.gsub('/', '__')}-#{"%06d" % rand(999999)}.dump"
    start = Time.now
    profile = StackProf.run(mode: :cpu, raw: true) do
      a.update_index
    end
    duration = Time.now - start
    File.open(pout+"-time", "w") do |f|
      f.puts "#{duration} seconds"
    end

    report = StackProf::Report.new(profile)
    File.open(pout, "w") do |f|
      report.print_text(false, nil, nil, nil, nil, nil, f)
    end
    File.open(pout+"-viz", "w") do |f|
      report.print_graphviz({}, f)
    end

    contains_pids.each { |pid| ActiveFedora::Base.find(pid).update_index }

    FetchGraphWorker.perform_async(asset_pid, a.depositor) if a.respond_to?(:depositor)
  end
end
