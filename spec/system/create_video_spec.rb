# frozen_string_literal:true

RSpec.describe 'Create a Video',  js: true, type: :system do
  context 'with a logged in user' do
    let(:user) { create(:user) }
    let!(:ability) { ::Ability.new(user) }
    let(:upload_file_path) { "#{Rails.root}/spec/fixtures/test.jpg" }

    before do
      create(:permission_template_access,
             :deposit,
             permission_template: create(:permission_template, with_admin_set: true, with_active_workflow: true),
             agent_type: 'user',
             agent_id: user.user_key)
      allow(CharacterizeJob).to receive(:perform_later)
      sign_in_as user
    end

    # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
    it do
      visit new_hyrax_video_path

      expect(page).to have_content 'Add New Video'
      click_link 'Files' # switch tab
      expect(page).to have_content 'Add files'
      expect(page).to have_content 'Add folder'
      within('span#addfiles') do
        page.execute_script("$('input[type=file]').css('opacity','1')")
        page.execute_script("$('input[type=file]').css('position','inherit')")
        attach_file('files[]', upload_file_path)
      end
      click_link 'Descriptions' # switch tab
      within('div.video_title') do
        fill_in('Title', with: 'Test Title')
      end
      select('In Copyright', from: 'Rights')
      fill_in('Dcmi type', with: 'test type')
      # Selenium/chrome on CircleCI requires the focus to change after the previous method
      find('body').click

      choose('video_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')
      # Selenium/chrome on CircleCI requires the focus to change after the previous method
      find('body').click

      check('agreement', visible: false)
      # Selenium/chrome on CircleCI requires the focus to change after the previous method
      find('body').click

      click_on 'Save'
      expect(page).to have_content('Test Title')
      expect(page).to have_content 'Your files are being processed by Hyrax in the background.'

      # save a successful screenshot if running in CI for build artifacts
      # rubocop:disable Lint/Debugger
      save_screenshot if ENV.fetch('CI', nil)
      # rubocop:enable Lint/Debugger
    end
    # rubocop:enable RSpec/MultipleExpectations, RSpec/ExampleLength
  end
end
