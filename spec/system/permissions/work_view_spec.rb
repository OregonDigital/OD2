# frozen_string_literal:true

RSpec.describe 'View various works', js: true, type: :system, clean_repo: true do
  let(:public_reviewed) { create(:work, title: ['public_reviewed'], depositor: 'foo@bar.baz', id: 1, visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC, state: Vocab::FedoraResourceStatus.active) }
  let(:public_unreviewed) { create(:work, title: ['public_unreviewed'], depositor: 'foo@bar.baz', id: 2, visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC, state: Vocab::FedoraResourceStatus.inactive) }
  let(:osu_reviewed) { create(:work, title: ['osu_reviewed'], depositor: 'foo@bar.baz', id: 3, visibility: 'osu', state: Vocab::FedoraResourceStatus.active) }
  let(:osu_unreviewed) { create(:work, title: ['osu_unreviewed'], depositor: 'foo@bar.baz', id: 4, visibility: 'osu', state: Vocab::FedoraResourceStatus.inactive) }
  let(:uo_reviewed) { create(:work, title: ['uo_reviewed'], depositor: 'foo@bar.baz', id: 5, visibility: 'uo', state: Vocab::FedoraResourceStatus.active) }
  let(:uo_unreviewed) { create(:work, title: ['uo_unreviewed'], depositor: 'foo@bar.baz', id: 6, visibility: 'uo', state: Vocab::FedoraResourceStatus.inactive) }
  let(:private_reviewed) { create(:work, title: ['private_reviewed'], depositor: 'foo@bar.baz', id: 7, visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE, state: Vocab::FedoraResourceStatus.active) }
  let(:private_unreviewed) { create(:work, title: ['private_unreviewed'], depositor: 'foo@bar.baz', id: 8, visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE, state: Vocab::FedoraResourceStatus.inactive) }
  let(:out_adminset) { create(:work, title: ['out_adminset'], depositor: 'foo@bar.baz', id: 9, visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE, state: Vocab::FedoraResourceStatus.inactive, admin_set_id: out_set.id) }
  let(:in_adminset) { create(:work, title: ['in_adminset'], depositor: 'foo@bar.baz', id: 10, visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE, state: Vocab::FedoraResourceStatus.inactive, admin_set_id: in_set.id) }
  let(:user) { create(:user) }
  let!(:ability) { ::Ability.new(user) }
  let(:out_set) { create(:admin_set) }
  let(:in_set) { create(:admin_set) }

  before do
    public_reviewed.save!
    public_unreviewed.save!
    osu_reviewed.save!
    osu_unreviewed.save!
    uo_reviewed.save!
    uo_unreviewed.save!
    private_reviewed.save!
    private_unreviewed.save!
    out_adminset.save!
    in_adminset.save!
  end

  context 'with an unauthenticated user' do
    it 'Shows reviewed public works' do
      visit hyrax_generic_path public_reviewed.id

      expect(page).to have_content 'MLA Citation'
    end

    it 'Blocks unreviewed public works' do
      visit hyrax_generic_path public_unreviewed.id

      expect(page).to have_content 'not currently available'
    end

    it 'Blocks non-public works' do
      visit hyrax_generic_path osu_reviewed.id
      expect(page).to have_content 'not authorized'

      visit hyrax_generic_path osu_unreviewed.id
      expect(page).to have_content 'not authorized'

      visit hyrax_generic_path uo_reviewed.id
      expect(page).to have_content 'not authorized'

      visit hyrax_generic_path uo_unreviewed.id
      expect(page).to have_content 'not authorized'

      visit hyrax_generic_path private_reviewed.id
      expect(page).to have_content 'not authorized'

      visit hyrax_generic_path private_unreviewed.id
      expect(page).to have_content 'not authorized'
    end
  end

  context 'without any roles' do
    before do
      sign_in_as user
    end

    it 'Shows reviewed public works' do
      visit hyrax_generic_path public_reviewed.id

      expect(page).to have_content 'MLA Citation'
    end

    it 'blocks unreviewed public works' do
      visit hyrax_generic_path public_unreviewed.id

      expect(page).to have_content 'not currently available'
    end

    it 'Blocks non-public works' do
      visit hyrax_generic_path osu_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit hyrax_generic_path osu_unreviewed.id
      expect(page).to have_content 'Unauthorized'

      visit hyrax_generic_path uo_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit hyrax_generic_path uo_unreviewed.id
      expect(page).to have_content 'Unauthorized'

      visit hyrax_generic_path private_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit hyrax_generic_path private_unreviewed.id
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

    it 'Shows reviewed public works' do
      visit hyrax_generic_path public_reviewed.id

      expect(page).to have_content 'MLA Citation'
    end

    it 'blocks unreviewed public works' do
      visit hyrax_generic_path public_unreviewed.id

      expect(page).to have_content 'not currently available'
    end

    it 'Shows reviewed OSU and UO works' do
      visit hyrax_generic_path osu_reviewed.id
      expect(page).to have_content 'MLA Citation'

      visit hyrax_generic_path uo_reviewed.id
      expect(page).to have_content 'MLA Citation'
    end

    it 'Blocks unreviewed works' do
      visit hyrax_generic_path osu_unreviewed.id
      expect(page).to have_content 'not currently available'

      visit hyrax_generic_path uo_unreviewed.id
      expect(page).to have_content 'not currently available'

      visit hyrax_generic_path private_unreviewed.id
      expect(page).to have_content 'Unauthorized'
    end

    it 'Blocks private works' do
      visit hyrax_generic_path private_reviewed.id
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

    it 'Shows reviewed public works' do
      visit hyrax_generic_path public_reviewed.id

      expect(page).to have_content 'MLA Citation'
    end

    it 'blocks unreviewed public works' do
      visit hyrax_generic_path public_unreviewed.id

      expect(page).to have_content 'not currently available'
    end

    it 'Shows reviewed OSU works' do
      visit hyrax_generic_path osu_reviewed.id
      expect(page).to have_content 'MLA Citation'
    end

    it 'Blocks UO works' do
      visit hyrax_generic_path uo_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit hyrax_generic_path uo_unreviewed.id
      expect(page).to have_content 'Unauthorized'
    end

    it 'Blocks unreviewed works' do
      visit hyrax_generic_path osu_unreviewed.id
      expect(page).to have_content 'not currently available'

      visit hyrax_generic_path private_unreviewed.id
      expect(page).to have_content 'Unauthorized'
    end

    it 'Blocks private works' do
      visit hyrax_generic_path private_reviewed.id
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

    it 'Shows reviewed public works' do
      visit hyrax_generic_path public_reviewed.id

      expect(page).to have_content 'MLA Citation'
    end

    it 'blocks unreviewed public works' do
      visit hyrax_generic_path public_unreviewed.id

      expect(page).to have_content 'not currently available'
    end

    it 'Shows reviewed UO works' do
      visit hyrax_generic_path uo_reviewed.id
      expect(page).to have_content 'MLA Citation'
    end

    it 'Blocks OSU works' do
      visit hyrax_generic_path osu_reviewed.id
      expect(page).to have_content 'Unauthorized'

      visit hyrax_generic_path osu_unreviewed.id
      expect(page).to have_content 'Unauthorized'
    end

    it 'Blocks unreviewed works' do
      visit hyrax_generic_path uo_unreviewed.id
      expect(page).to have_content 'not currently available'

      visit hyrax_generic_path private_unreviewed.id
      expect(page).to have_content 'Unauthorized'
    end

    it 'Blocks private works' do
      visit hyrax_generic_path private_reviewed.id
      expect(page).to have_content 'Unauthorized'
    end
  end

  context 'with depositor role' do
    let(:role) { Role.new(name: 'depositor') }

    before do
      create(:permission_template_access,
             :deposit,
             permission_template: create(:permission_template, with_admin_set: true, source_id: out_set.id, with_active_workflow: true),
             agent_type: 'user')
      create(:permission_template_access,
             :deposit,
             permission_template: create(:permission_template, with_admin_set: true, source_id: in_set.id, with_active_workflow: true),
             agent_type: 'user')
      user.roles = [role]
      user.save
      sign_in_as user
    end

    it 'Shows reviewed works' do
      visit hyrax_generic_path public_reviewed.id
      expect(page).to have_content 'MLA Citation'

      visit hyrax_generic_path osu_reviewed.id
      expect(page).to have_content 'MLA Citation'

      visit hyrax_generic_path uo_reviewed.id
      expect(page).to have_content 'MLA Citation'

      visit hyrax_generic_path private_reviewed.id
      expect(page).to have_content 'MLA Citation'
    end

    it 'Shows unreviewed works I can deposit into' do
      visit hyrax_generic_path in_adminset.id
      expect(page).to have_content 'MLA Citation'
    end

    it 'Blocks unreviewed works I cannot deposit into' do
      visit hyrax_generic_path out_adminset.id
      expect(page).to have_content 'not currently available'
    end
  end

  context 'with collection curator role' do
    let(:role) { Role.new(name: 'collection_curator') }

    before do
      create(:permission_template_access,
             :manage,
             permission_template: create(:permission_template, with_admin_set: true, source_id: out_set.id, with_active_workflow: true),
             agent_type: 'user')
      create(:permission_template_access,
             :manage,
             permission_template: create(:permission_template, with_admin_set: true, source_id: in_set.id, with_active_workflow: true),
             agent_type: 'user')
      user.roles = [role]
      user.save
      sign_in_as user
    end

    it 'Shows reviewed works' do
      visit hyrax_generic_path public_reviewed.id
      expect(page).to have_content 'MLA Citation'

      visit hyrax_generic_path osu_reviewed.id
      expect(page).to have_content 'MLA Citation'

      visit hyrax_generic_path uo_reviewed.id
      expect(page).to have_content 'MLA Citation'

      visit hyrax_generic_path private_reviewed.id
      expect(page).to have_content 'MLA Citation'
    end

    it 'Shows unreviewed works I can manage' do
      visit hyrax_generic_path in_adminset.id
      expect(page).to have_content 'MLA Citation'
    end

    it 'Blocks unreviewed works I cannot manage' do
      visit hyrax_generic_path out_adminset.id
      expect(page).to have_content 'not currently available'
    end
  end

  context 'with admin role' do
    let(:role) { Role.new(name: 'admin') }

    before do
      user.roles = [role]
      user.save
      sign_in_as user
    end

    it 'Shows all works' do
      visit hyrax_generic_path public_reviewed.id
      expect(page).to have_content 'MLA Citation'

      visit hyrax_generic_path public_unreviewed.id
      expect(page).to have_content 'MLA Citation'

      visit hyrax_generic_path osu_reviewed.id
      expect(page).to have_content 'MLA Citation'

      visit hyrax_generic_path osu_unreviewed.id
      expect(page).to have_content 'MLA Citation'

      visit hyrax_generic_path uo_reviewed.id
      expect(page).to have_content 'MLA Citation'

      visit hyrax_generic_path uo_unreviewed.id
      expect(page).to have_content 'MLA Citation'

      visit hyrax_generic_path private_reviewed.id
      expect(page).to have_content 'MLA Citation'

      visit hyrax_generic_path private_unreviewed.id
      expect(page).to have_content 'MLA Citation'
    end
  end
end
