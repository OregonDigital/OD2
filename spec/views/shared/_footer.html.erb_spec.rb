# frozen_string_literal:true

RSpec.describe 'shared/_footer', type: :view do
  include Warden::Test::Helpers
  it 'renders the application version' do
    render
    expect(rendered).to have_text(OregonDigital::VERSION)
  end
end
