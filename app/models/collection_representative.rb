# frozen_string_literal:true

# Representative fileset entry for a collection
class CollectionRepresentative < ApplicationRecord
  def fs_title
    fileset_id.empty? ? '' : FileSet.find(fileset_id).title.first
  end
end
