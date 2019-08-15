# frozen_string_literal:true

# Sets the expected behaviors for file sets
class FileSet < ActiveFedora::Base
  include ::Hyrax::FileSetBehavior

  alias_method :old_destroy, :destroy

  # Queues a job to destroy all derivatives, then destroys itself
  def destroy
    destroy_derivatives
    old_destroy
  end

  private

  def path_factory
    OregonDigital::DerivativePath.new(bucket: ENV['AWS_S3_DERIVATIVES_BUCKET'], id: id)
  end

  def destroy_derivatives
    path_factory.all_urls.each {|url| queue_destroy_job(url)}
  end

  def queue_destroy_job(url)
    Sidekiq::Client.new.push(
      'queue' => 'derivatives',
      'class' => 'DestroyS3Derivative',
      'args' => [url],
    )
  end
end
