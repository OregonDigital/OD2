# frozen_string_literal:true

# Sets basic object for a local authority
class Qa::LocalAuthorityEntry < ApplicationRecord
  belongs_to :local_authority
end
