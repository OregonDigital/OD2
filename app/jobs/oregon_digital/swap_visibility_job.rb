# frozen_string_literal: true

# Swaps the visibility of an object as a job
class OregonDigital::SwapVisibilityJob < ContentEventJob
  def perform(work, visibility)
    work.visibility = visibility
    work.save
    Hyrax::VisibilityPropagator.for(source: work).propagate
    OregonDigital::PermissionChangePropagationJob.perform_later(work)
  end
end
