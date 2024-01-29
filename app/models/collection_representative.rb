# frozen_string_literal:true

# Representative fileset entry for a collection
class CollectionRepresentative < ApplicationRecord
  def fs_title
    fileset_id.empty? ? '' : Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: fileset_id).title.first
  end
end
