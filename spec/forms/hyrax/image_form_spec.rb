# frozen_string_literal:true

RSpec.describe Hyrax::ImageForm do
  let(:new_form) { described_class.new(Image.new, nil, instance_double('Controller')) }
  let(:user) { create(:user) }
  let(:ability) { instance_double('Ability') }
  let(:props) do
    %i[title resource_type rights_statement identifier]
  end
  let(:terms) { new_form.primary_terms + new_form.secondary_terms }
  let(:model) { create(:image) }

  before do
    allow(new_form).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:current_user).and_return(user)
  end

  it 'responds to terms with the proper list of terms' do
    props.each do |t|
      expect(terms).to include(t)
    end
  end

  it 'matches terms to model properties' do
    terms.each do |term|
      expect(model).to respond_to(term)
    end
  end
end
