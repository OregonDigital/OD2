# frozen_string_literal: true

require 'docker/stack/rake_task'

def get_named_task(task_name)
  Rake::Task[task_name]
rescue RuntimeError
  nil
end

namespace :docker do
  namespace(:dev)  { Docker::Stack::RakeTask.load_tasks }
  namespace(:test) { Docker::Stack::RakeTask.load_tasks(force_env: 'test', cleanup: true) }

  desc 'Spin up test stack and run specs'
  task :spec do
    Rails.env = 'test'
    Docker::Stack::Controller.new(cleanup: true).with_containers do
      Rake::Task['db:setup'].invoke

      task = get_named_task(ENV['SPEC_TASK']) ||
             get_named_task('spec') ||
             get_named_task('rspec')
      task&.invoke
    end
  end
end
