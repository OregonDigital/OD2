# frozen_string_literal:true
include Warden::Test::Helpers

RSpec.describe 'shared/_footer', type: :view do
  it 'renders the application version' do
    render
    expect(rendered).to have_text(OregonDigital::VERSION)
  end
end
