# frozen_string_literal: true
Dir[File.dirname(__FILE__) + '/controlled_vocabularies/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/controlled_vocabularies/vocabularies/*.rb'].each {|file| require file }

module OregonDigital
  # Autoloads controlled vocabulary objects
  module ControlledVocabularies
    extend ActiveSupport::Autoload
  end
end
