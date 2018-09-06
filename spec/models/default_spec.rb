# frozen_string_literal: true

require 'valkyrie/specs/shared_specs'

RSpec.describe Default do
  let(:resource_klass) { described_class }
  it_behaves_like "a Valkyrie::Resource"

  it "has tests" do
    skip "Add your tests here"
  end
end
