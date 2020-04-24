# frozen_string_literal:true

# Sets the expected behaviors for file sets
class FileSet < ActiveFedora::Base
  include ::Hyrax::FileSetBehavior
  include OregonDigital::AccessControls::Visibility
  attr_accessor :ocr_content, :hocr_content
end
