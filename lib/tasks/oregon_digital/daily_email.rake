# frozen_string_literal: true

namespace :oregon_digital do
  desc 'Send out daily email to users based on if changes/review is require'
  task daily_email: :environment do
    # Grab all the users
    user_list = User.all

    # Needed variables
    review_users = []
    changes_users = []
    review_items = []
    changes_items = []

    # Grab the entities in a specific workflow
    review_entities = Sipity::Workflow.all.first.workflow_states.where(name: 'pending_review').first.entities
    changes_entities = Sipity::Workflow.all.first.workflow_states.where(name: 'changes_required').first.entities

    # For each entitiy, grab the object if the entity was updated on "Today"
    review_entities.each do |e|
      review_items << ActiveFedora::Base.find(e.proxy_for_global_id.split('/').last) if e.updated_at.to_date == Date.today
    end

    changes_entities.each do |e|
      changes_items << ActiveFedora::Base.find(e.proxy_for_global_id.split('/').last) if e.updated_at.to_date == Date.today
    end

    # Check to see if any users have the ability to review the objects
    user_list.each do |u|
      review_items.each do |i|
        review_users << u if u.can?(:review, i)
      end
    end

    # get all users that have items in the changes required step
    changes_items.each do |i|
      changes_users << User.where(email: i.depositor)
    end

    # email review users with list of
    changes_users.each do |user|
      OregonDigital::NotificationMailer.with(user: user, need_keyword: 'changes').deliver_now
    end
    review_users.each do |user|
      OregonDigital::NotificationMailer.with(user: user, need_keyword: 'reviews').deliver_now
    end
  end
end
