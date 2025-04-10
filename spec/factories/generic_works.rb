# frozen_string_literal:true

FactoryBot.define do
  factory :work, class: Generic do
    transient do
      user { create(:user) }
      # Set to true (or a hash) if you want to create an admin set
      with_admin_set { false }
    end

    # It is reasonable to assume that a work has an admin set; However, we don't want to
    # go through the entire rigors of creating that admin set.
    before(:create) do |work, evaluator|
      if evaluator.with_admin_set
        attributes = {}
        attributes[:id] = work.admin_set_id if work.admin_set_id.present?
        attributes = evaluator.with_admin_set.merge(attributes) if evaluator.with_admin_set.respond_to?(:merge)
        admin_set = create(:admin_set, attributes)
        work.admin_set_id = admin_set.id
      end
    end

    after(:create) do |work, _evaluator|
      work.save! if work.member_of_collections.present?
    end

    title { ['Test title'] }
    id { ::Noid::Rails::Service.new.minter.mint }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    resource_type { 'http://purl.org/dc/dcmitype/Text' }
    rights_statement { ['http://rightsstatements.org/vocab/InC/1.0/'] }
    identifier { ['MyIdentifier'] }

    after(:build) do |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
    end

    factory :work_with_ten_children do
      before(:create) do |work, evaluator|
        work.visibility = 'open'
        (0..9).each do |i|
          work.ordered_members << create(:work, user: evaluator.user, title: ["Child #{i}"], id: "abcde123#{i}", visibility: 'open')
        end
      end
    end
  end
end
