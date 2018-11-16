module OD2
  module VideoPresenterBehavior
    extend ActiveSupport::Concern
    included do
      delegate :height,
               :width
    end
  end
end
