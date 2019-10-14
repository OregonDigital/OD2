# frozen_string_literal:true

RSpec.describe 'Edit various works', js: true, type: :system, clean_repo: true do
  let(:public_reviewed) { create(:work, title: ['public_reviewed'], depositor: 'foo@bar.baz', id: 1, visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC, state: Vocab::FedoraResourceStatus.active) }
  let(:public_unreviewed) { create(:work, title: ['public_unreviewed'], depositor: 'foo@bar.baz', id: 2, visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC, state: Vocab::FedoraResourceStatus.inactive) }
  let(:osu_reviewed) { create(:work, title: ['osu_reviewed'], depositor: 'foo@bar.baz', id: 3, visibility: 'osu', state: Vocab::FedoraResourceStatus.active) }
  let(:osu_unreviewed) { create(:work, title: ['osu_unreviewed'], depositor: 'foo@bar.baz', id: 4, visibility: 'osu', state: Vocab::FedoraResourceStatus.inactive) }
  let(:uo_reviewed) { create(:work, title: ['uo_reviewed'], depositor: 'foo@bar.baz', id: 5, visibility: 'uo', state: Vocab::FedoraResourceStatus.active) }
  let(:uo_unreviewed) { create(:work, title: ['uo_unreviewed'], depositor: 'foo@bar.baz', id: 6, visibility: 'uo', state: Vocab::FedoraResourceStatus.inactive) }
  let(:private_reviewed) { create(:work, title: ['private_reviewed'], depositor: 'foo@bar.baz', id: 7, visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE, state: Vocab::FedoraResourceStatus.active) }
  let(:private_unreviewed) { create(:work, title: ['private_unreviewed'], depositor: 'foo@bar.baz', id: 8, visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE, state: Vocab::FedoraResourceStatus.inactive) }
  let(:user) { create(:user) }
  let!(:ability) { ::Ability.new(user) }

  before do
    public_reviewed.save!
    public_unreviewed.save!
    osu_reviewed.save!
    osu_unreviewed.save!
    uo_reviewed.save!
    uo_unreviewed.save!
    private_reviewed.save!
    private_unreviewed.save!
  end

  context 'with an unauthenticated user' do
    it 'Blocks all works' do
      visit edit_hyrax_generic_path public_reviewed.id
      expect(page).to have_content 'not authorized'

      visit edit_hyrax_generic_path public_unreviewed.id
      expect(page).to have_content 'not authorized'

      visit edit_hyrax_generic_path osu_reviewed.id
      expect(page).to have_content 'not authorized'

      visit edit_hyrax_generic_path osu_unreviewed.id
      expect(page).to have_content 'not authorized'

      visit edit_hyrax_generic_path uo_reviewed.id
      expect(page).to have_content 'not authorized'

      visit edit_hyrax_generic_path uo_unreviewed.id
      expect(page).to have_content 'not authorized'

      visit edit_hyrax_generic_path private_reviewed.id
      expect(page).to have_content 'not authorized'

      visit edit_hyrax_generic_path private_unreviewed.id
      expect(page).to have_content 'not authorized'
    end
  end

  context 'without any roles' do
    before do
      sign_in_as user
    end

    it 'Blocks all works' do
      visit edit_hyrax_generic_path public_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path public_unreviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path osu_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path osu_unreviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path uo_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path uo_unreviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path private_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path private_unreviewed.id
      expect(page).to have_content 'Unauthorized'
    end
  end

  context 'with community affiliate role' do
    let(:role) { Role.new(name: 'community_affiliate') }

    before do
      user.roles = [role]
      user.save
      sign_in_as user
    end

    it 'Blocks all works' do
      visit edit_hyrax_generic_path public_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path public_unreviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path osu_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path osu_unreviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path uo_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path uo_unreviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path private_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path private_unreviewed.id
      expect(page).to have_content 'Unauthorized'
    end
  end

  context 'with osu role' do
    let(:role) { Role.new(name: 'osu_user') }

    before do
      user.roles = [role]
      user.save
      sign_in_as user
    end

    it 'Blocks all works' do
      visit edit_hyrax_generic_path public_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path public_unreviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path osu_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path osu_unreviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path uo_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path uo_unreviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path private_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path private_unreviewed.id
      expect(page).to have_content 'Unauthorized'
    end
  end

  context 'with uo role' do
    let(:role) { Role.new(name: 'uo_user') }

    before do
      user.roles = [role]
      user.save
      sign_in_as user
    end

    it 'Blocks all works' do
      visit edit_hyrax_generic_path public_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path public_unreviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path osu_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path osu_unreviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path uo_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path uo_unreviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path private_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path private_unreviewed.id
      expect(page).to have_content 'Unauthorized'
    end
  end

  context 'with depositor role' do
    let(:role) { Role.new(name: 'depositor') }
    let(:deposited) { create(:work, title: ['deposited'], id: 9, visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC, state: Vocab::FedoraResourceStatus.active) }

    before do
      user.roles = [role]
      user.save
      sign_in_as user

      deposited.depositor = user.email
      deposited.save
    end

    it 'Allows self deposited works' do
      visit edit_hyrax_generic_path deposited.id
      expect(page).to have_content 'deposited'
    end

    it 'Blocks non-deposited works' do
      visit edit_hyrax_generic_path public_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path public_unreviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path osu_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path osu_unreviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path uo_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path uo_unreviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path private_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit edit_hyrax_generic_path private_unreviewed.id
      expect(page).to have_content 'Unauthorized'
    end
  end

  context 'with collection curator role' do
    let(:role) { Role.new(name: 'collection_curator') }

    before do
      user.roles = [role]
      user.save
      sign_in_as user
    end

    it 'Allows all works' do
      visit edit_hyrax_generic_path public_reviewed.id
      expect(page).to have_content 'public_reviewed'

      visit edit_hyrax_generic_path public_unreviewed.id
      expect(page).to have_content 'public_unreviewed'

      visit edit_hyrax_generic_path osu_reviewed.id
      expect(page).to have_content 'osu_reviewed'

      visit edit_hyrax_generic_path osu_unreviewed.id
      expect(page).to have_content 'osu_unreviewed'

      visit edit_hyrax_generic_path uo_reviewed.id
      expect(page).to have_content 'uo_reviewed'

      visit edit_hyrax_generic_path uo_unreviewed.id
      expect(page).to have_content 'uo_unreviewed'

      visit edit_hyrax_generic_path private_reviewed.id
      expect(page).to have_content 'private_reviewed'

      visit edit_hyrax_generic_path private_unreviewed.id
      expect(page).to have_content 'private_unreviewed'
    end
  end

  context 'with admin role' do
    let(:role) { Role.new(name: 'admin') }

    before do
      user.roles = [role]
      user.save
      sign_in_as user
    end

    it 'Allows all works' do
      visit edit_hyrax_generic_path public_reviewed.id
      expect(page).to have_content 'public_reviewed'

      visit edit_hyrax_generic_path public_unreviewed.id
      expect(page).to have_content 'public_unreviewed'

      visit edit_hyrax_generic_path osu_reviewed.id
      expect(page).to have_content 'osu_reviewed'

      visit edit_hyrax_generic_path osu_unreviewed.id
      expect(page).to have_content 'osu_unreviewed'

      visit edit_hyrax_generic_path uo_reviewed.id
      expect(page).to have_content 'uo_reviewed'

      visit edit_hyrax_generic_path uo_unreviewed.id
      expect(page).to have_content 'uo_unreviewed'

      visit edit_hyrax_generic_path private_reviewed.id
      expect(page).to have_content 'private_reviewed'

      visit edit_hyrax_generic_path private_unreviewed.id
      expect(page).to have_content 'private_unreviewed'
    end
  end
end
