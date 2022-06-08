# frozen_string_literal:true

RSpec.describe 'Create a Generic', js: true, type: :system, clean_repo: true do
  context 'with a logged in user' do
    let(:user) do
      u = create(:user)
      r = role
      r.users << u
      r.save
      u
    end
    let(:role) { Role.create(name: 'admin') }
    let!(:ability) { ::Ability.new(user) }
    let(:upload_file_path) { "#{Rails.root}/spec/fixtures/test.jpg" }

    before do
      create(:permission_template_access,
             :deposit,
             permission_template: create(:permission_template, with_admin_set: true, with_active_workflow: true),
             agent_type: 'user',
             agent_id: user.user_key)
      create(:adminset_lw, user: user, with_permission_template: true, id: '1234')
      allow(CharacterizeJob).to receive(:perform_later)
      sign_in_as user
    end

    it 'Creates an Generic' do
      visit new_hyrax_generic_path

      expect(page).to have_content 'Add New Generic'
      click_link 'Files' # switch tab
      expect(page.body).to have_content 'Add files...'
      expect(page.body).to have_content 'Add folder...'
      within('div#add-files') do
        page.execute_script("$('input[type=file]').css('opacity','1')")
        page.execute_script("$('input[type=file]').css('position','inherit')")
        attach_file('files[]', upload_file_path, visible: false)
      end
      within('ul.nav-tabs') do
        click_link 'Relationships'
      end
      find("#generic_admin_set_id option[value='1234']").select_option
      within('ul.nav-tabs') do
        click_link 'Descriptions' # switch tab
      end
      within('div.generic_title') do
        fill_in('Title', with: 'Test Title')
      end
      within('div.generic_identifier') do
        fill_in('Identifier', with: 'Test ID')
      end
      within('div.generic_resource_type') do
        select('Dataset', from: 'Resource type')
      end
      select('In Copyright', from: 'Rights')

      # Selenium/chrome on CircleCI requires the focus to change after the previous method
      find('#required-metadata').click

      choose('generic_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
      # Selenium/chrome on CircleCI requires the focus to change after the previous method
      find('#required-metadata').click

      check('agreement', visible: false)
      # Selenium/chrome on CircleCI requires the focus to change after the previous method
      find('#required-metadata').click

      click_on 'Save'
      expect(page).to have_content('Test Title')
      expect(page).to have_content 'Your files are being processed by Oregon Digital (Development) in the background.'
      expect(page).to be_accessible.skipping('aria-allowed-role').excluding('.label-success')

      # save a successful screenshot if running in CI for build artifacts
      # rubocop:disable Lint/Debugger
      save_screenshot if ENV.fetch('CI', nil)
      # rubocop:enable Lint/Debugger
    end
  end
end
