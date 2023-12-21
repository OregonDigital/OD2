# frozen_string_literal:true

RSpec.describe 'Create a Document', js: true, type: :system, clean_repo: true do
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

    it 'Creates an Document' do
      visit new_hyrax_document_path

      expect(page).to have_content 'Add New Document'
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
      first_element = find('#document_admin_set_id > option:nth-child(2)').text
      select(first_element, from: 'document_admin_set_id')
      within('ul.nav-tabs') do
        click_link 'Descriptions' # switch tab
      end
      within('div.document_title') do
        fill_in('Title', with: 'Test Title')
      end
      within('div.document_identifier') do
        fill_in('Identifier', with: 'Test ID')
      end
      within('div.document_resource_type') do
        select('Dataset', from: 'Resource type')
      end
      select('In Copyright', from: 'Rights')
      # Selenium/chrome on CircleCI requires the focus to change after the previous method
      find('#required-metadata').click

      choose('document_visibility_open')
      expect(page).to have_content('Make available to all.')
      # Selenium/chrome on CircleCI requires the focus to change after the previous method
      find('#required-metadata').click

      # Selenium/chrome on CircleCI requires the focus to change after the previous method
      find('#required-metadata').click

      click_on 'Save'
      expect(page).to have_content('Test Title')
      expect(page).to have_content "Your files are being processed by #{I18n.t('hyrax.product_name')} in the background."
      expect(page).to be_accessible.skipping('aria-allowed-role').excluding('.label-success')

      # save a successful screenshot if running in CI for build artifacts
      # rubocop:disable Lint/Debugger
      save_screenshot if ENV.fetch('CI', nil)
      # rubocop:enable Lint/Debugger
    end
  end
end
