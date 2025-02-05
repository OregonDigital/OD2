# frozen_string_literal:true

# TODO: Remove once valkyrized
Rails.application.config.to_prepare do
  Hyrax::Collections::CollectionMemberService.class_eval do

    class << self
      # Add a work or collection as a member of a collection
      # @param collection_id [Valkyrie::ID] the id of the parent collection
      # @param new_member [Hyrax::Resource] the new child collection or child work
      # @return [Hyrax::Resource] updated member resource
      def add_member(collection_id:, new_member:, user:)
        message = Hyrax::MultipleMembershipChecker.new(item: new_member).check(collection_ids: [collection_id], include_current_members: true)
        raise Hyrax::SingleMembershipError, message if message.present?
        new_member.member_of_collection_ids << collection_id # only populate this direction
        new_member = Hyrax.query_service.resource_factory.from_resource(resource: new_member) unless Hyrax.config.use_valkyrie?

        # OVERRIDE FROM HYRAX: Use AF or Valkyrie based on Hyrax config
        new_member = case new_member
        when ActiveFedora::Base
          new_member.save
          new_member.valkyrie_resource
        else
          Hyrax.persister.save(resource: new_member)
        end

        publish_metadata_updated(new_member, user)
        new_member
      end

      # Remove a collection or work from the members set of a collection, also removing the inverse relationship
      # @param collection_id [Valkyrie::ID] the id of the parent collection
      # @param member [Hyrax::Resource] the child collection or child work to be removed
      # @return [Hyrax::Resource] updated member resource
      def remove_member(collection_id:, member:, user:)
        return member unless member?(collection_id: collection_id, member: member)
        member.member_of_collection_ids.delete(collection_id)
        member = Hyrax.query_service.resource_factory.from_resource(resource: member) unless Hyrax.config.use_valkyrie?

        # OVERRIDE FROM HYRAX: Use AF or Valkyrie based on Hyrax config
        member = case member
        when ActiveFedora::Base
          member.save
          member.valkyrie_resource
        else
          Hyrax.persister.save(resource: member)
        end

        publish_metadata_updated(member, user)
        member
      end
    end
  end
end
