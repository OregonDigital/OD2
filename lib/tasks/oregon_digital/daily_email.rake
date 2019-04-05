# frozen_string_literal: true

namespace :oregon_digital do
  desc 'Get the OregonDigital application version'
  task :daily_email do
    #Grab all the users
    user_list = User.all

    #Needed variables
    review_users, change_users, review_items, changes_items = []
    review_hash = {}

    # Grab the entities in a specific workflow
    review_entities = Sipity::Workflow.all.first.workflow_states.where(name: "pending_review").entities
    changes_entities = Sipity::Workflow.all.first.workflow_states.where(name: "changes_required").entities 

    # For each entitiy, grab the object
    review_entities.each do |e| 
      review_items << ActiveFedora::Base.find(e.proxy_for_global_id.split('/').last)
    end

    changes_entities.each do |e|
      changes_items << ActiveFedora::Base.find(e.proxy_for_global_id.split('/').last) 
    end

    # Check to see if any users have the ability to review the objects
    user_list.each do |u|
      review_hash[u.email] = []
      review_items.each do |i|
        review_hash[u.email] << i if u.can?(:review, i)
      end
    end

    # get all users that have items in the changes required step 
    changes_items.each do |i|
      change_users << User.where(email: i.depositor)
    end

    # email review users with list of

  end
end
