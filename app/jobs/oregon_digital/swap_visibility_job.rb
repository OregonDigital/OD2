# frozen_string_literal: true

# reindexes chunks of uris
class OregonDigital::SwapVisibilityJob < ContentEventJob 
  def perform(work, visibility)
    work.visibility = visibility
    work.save
    Hyrax::VisibilityPropagator.for(source: work).propagate
    OregonDigital::PermissionChangePropagationJob.perform_later(work)
  end
end

