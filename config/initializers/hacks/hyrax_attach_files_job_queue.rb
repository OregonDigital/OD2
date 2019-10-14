# frozen_string_literal: true

Hyrax::AttachFilesToWorkJob.class_eval do
  queue_as OD2::Application.config.slow_queue
end
