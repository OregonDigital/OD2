module OregonDigital
  class OembedsController < ApplicationController
    include OregonDigital::OembedsControllerBehavior

    with_themed_layout 'dashboard'
  end
end
