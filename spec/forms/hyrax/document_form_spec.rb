# frozen_string_literal:true

RSpec.describe Hyrax::DocumentForm do
  let(:new_form) { described_class.new(Document.new, nil, instance_double('Controller')) }
  let(:user) { create(:user) }
  let(:ability) { instance_double('Ability') }
  let(:props) { OregonDigital::DocumentMetadata::PROPERTIES.map(&:to_sym) }

  before do
    allow(new_form).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:current_user).and_return(user)
  end

  it 'responds to terms with the proper list of terms' do
    props.each do |prop|
      expect(described_class.terms).to include(prop)
    end
  end
end
