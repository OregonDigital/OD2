# frozen_string_literal:true

# Behaviors to add to Blacklight's RenderConstraintsHelper
module OregonDigital::RenderConstraintsHelperBehavior
  ##
  # Provide a url for removing a particular constraint. This can be overriden
  # in the case that you want parameters other than the defaults to be removed
  # (e.g. :search_field)
  #
  # @param [ActionController::Parameters] localized_params query parameters
  # @return [String]
  def remove_constraint_url(localized_params)
    scope = localized_params.delete(:route_set) || self

    localized_params = ActionController::Parameters.new(localized_params) unless localized_params.is_a? ActionController::Parameters

    # OVERRIDE FROM BLACKLIGHT: Don't remove `action` parameter
    options = localized_params.merge(q: nil)
    options.permit!
    scope.url_for(options)
  end
end
