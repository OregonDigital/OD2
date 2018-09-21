# Generated via
#  `rails generate hyrax:work DefaultHyrax`
module Hyrax
  # Generated form for DefaultHyrax
  class DefaultHyraxForm < Hyrax::Forms::WorkForm
    self.model_class = ::DefaultHyrax
    self.terms += [:resource_type]

    ##
    # Attempting to hack the form to use the decorated model instead..
    def initialize(model, current_ability, controller)
      model = HyraxModelDecorator.new(model)
      @current_ability = current_ability
      @agreement_accepted = !model.new_record?
      @controller = controller
      #super(model)
    end
  end
end
