class SingleValueSelectInput < MultiValueInput
  # Overriding so that the class is correct and the javascript for will work on this.
  # See https://github.com/samvera/hydra-editor/blob/4da9c0ea542f7fde512a306ec3cc90380691138b/app/assets/javascripts/hydra-editor/field_manager.es6#L61
  def input_type
    #'multi_value'.freeze
  end

  private

  def multiple?
    false
  end
end
