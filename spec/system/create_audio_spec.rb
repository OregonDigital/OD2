# frozen_string_literal:true

RSpec.describe 'Create a Audio', js: true, type: :system, clean_repo: true do
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
      create(:admin_set, id: '1234')
      allow(CharacterizeJob).to receive(:perform_later)
      sign_in_as user
    end

    it 'Creates an Audio' do
      visit new_hyrax_audio_path

      expect(page).to have_content 'Add New Audio'
      click_link 'Files' # switch tab
      expect(page.body).to have_content 'Add files...'
      expect(page.body).to have_content 'Add folder...'
      within('div#add-files') do
        page.execute_script("$('input[type=file]').css('opacity','1')")
        page.execute_script("$('input[type=file]').css('position','inherit')")
        attach_file('files[]', upload_file_path, visible: false)
      end

      within('ul.nav-tabs') do
        click_link 'Descriptions' # switch tab
      end
      within('div.audio_title') do
        fill_in('Title', with: 'Test Title')
      end
      within('div.audio_identifier') do
        fill_in('Identifier', with: 'Test ID')
      end
      within('div.audio_resource_type') do
        select('Dataset', from: 'Resource type')
      end
      select('In Copyright', from: 'Rights')
      # TODO: Rights statement list is missing from generic model, uncomment/resolve
      # line below when when rights_statement list is ready
      # select('In Copyright', from: 'Rights statement')
      # Selenium/chrome on CircleCI requires the focus to change after the previous method
      find('#required-metadata').click
      within('ul.nav-tabs') do
        click_link 'Relationships'
      end
      first_element = find('#audio_admin_set_id > option:nth-child(2)').text
      select(first_element, from: 'audio_admin_set_id')
      find('#required-metadata').click

      choose('audio_visibility_open')
      expect(page).to have_content('Make available to all.')
      # Selenium/chrome on CircleCI requires the focus to change after the previous method
      find('#required-metadata').click
      check('agreement', visible: false) if find('#agreement').visible?
      find('#required-metadata').click
      click_on('Save')
      # expect(page).to have_content('Test Title')
      # expect(page).to have_content "Your files are being processed by #{I18n.t('hyrax.product_name')} in the background."
      # expect(page).to be_accessible.skipping('aria-allowed-role').excluding('.label-success')

      # save a successful screenshot if running in CI for build artifacts
      # rubocop:disable Lint/Debugger
      save_screenshot if ENV.fetch('CI', nil)
      # rubocop:enable Lint/Debugger
    end
  end
end
