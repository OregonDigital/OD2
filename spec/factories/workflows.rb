# frozen_string_literal:true

FactoryBot.define do
  factory :workflow, class: Sipity::Workflow do
    sequence(:name) { |n| "workflow-#{n}" }
    permission_template
  end
end
