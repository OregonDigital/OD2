# frozen_string_literal:true

module OregonDigital
  # permission methods adapted from Hyrax::WorksControllerBehavior
  # in order to capture permissions changed events
  module CollectionsControllerBehavior
    def save_permissions
      @saved_permissions =
        case collection
        when ActiveFedora::Base
          collection.permissions.map(&:to_hash)
        else
          Hyrax::AccessControl.for(resource: collection).permissions
        end
    end

    def permissions_changed?
      @saved_permissions !=
        case collection
        when ActiveFedora::Base
          collection.permissions.map(&:to_hash)
        else
          Hyrax::AccessControl.for(resource: collection).permissions
        end
    end
  end
end
