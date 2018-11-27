module OregonDigital
  module ImageFormBehavior
    extend ActiveSupport::Concern
    included do
      self.terms += [:colour_content, :color_space, :height, :orientation, :photograph_orientation, :resolution, :view, :width]
    end
  end
end
