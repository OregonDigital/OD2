# frozen_string_literal:true

describe Ability do
  let(:ability) { described_class.new(user) }

  context 'when a user as an admin' do
    let(:ability) { described_class.new(user) }
    let(:user) do
      u = create(:user)
      r = role
      u.roles << r
      u.save
      u
    end
    let(:role) { Role.create(name: 'admin') }

    it { expect(ability).to be_able_to(:create, ActiveFedora::Base) }
    it { expect(ability).to be_able_to(:delete, ActiveFedora::Base) }
    it { expect(ability).to be_able_to(:show, ActiveFedora::Base) }

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

    it { expect(ability).to be_able_to(:create, ActiveFedora::Base) }
    it { expect(ability).to be_able_to(:delete, ActiveFedora::Base) }
    it { expect(ability).to be_able_to(:show, ActiveFedora::Base) }

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

    it { expect(ability).to be_able_to(:create, ActiveFedora::Base) }
    it { expect(ability).to be_able_to(:show, ActiveFedora::Base) }

    it 'can edit works' do
      Hyrax.config.curation_concerns.each do |type|
        expect(user).to be_able_to(:edit, type)
      end
    end
  end
end
