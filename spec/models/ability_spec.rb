# frozen_string_literal:true

describe Ability do
  let(:ability) { described_class.new(user) }

  context 'when a user is an admin' do
    let(:user) { create(:user) }
    let(:role) { Role.create(name: 'admin') }

    before do
      user.roles << role
      user.save
    end

    it 'can edit works' do
      Hyrax.config.curation_concerns.each do |type|
        expect(user).to be_able_to(:edit, type)
      end
    end
  end

  context 'when a user is a collection_curator' do
    let(:user) { create(:user) }
    let(:role) { Role.create(name: 'collection_curator') }

    before do
      user.roles << role
      user.save
    end

    it 'can edit works' do
      Hyrax.config.curation_concerns.each do |type|
        expect(user).to be_able_to(:edit, type)
      end
    end
  end

  context 'when a user is a depositor' do
    let(:user) { create(:user) }
    let(:role) { Role.create(name: 'depositor') }

    before do
      user.roles << role
      user.save
    end

    it 'can edit works' do
      Hyrax.config.curation_concerns.each do |type|
        expect(user).to be_able_to(:edit, type)
      end
    end
  end
end
  