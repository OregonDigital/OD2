Hyrax::AttachFilesToWorkJob.class_eval do
  queue_as config.slow_queue
end
