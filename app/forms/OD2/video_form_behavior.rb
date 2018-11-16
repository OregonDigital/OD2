module OD2
  module VideoFormBehavior
    extend ActiveSupport::Concern
    included do
      self.terms += [ :height, :width ]
    end
  end
end
