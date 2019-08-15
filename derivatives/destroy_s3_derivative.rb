# frozen_string_literal:true

# Runs the derivatives job for removing an S3 derivative object
class DestroyS3Derivative
  include Sidekiq::Worker

  def perform(url)
    S3.object(URI(url)).delete
  end
end
