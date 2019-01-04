# frozen_string_literal:true

# Application record can be used in place of activerecord
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
