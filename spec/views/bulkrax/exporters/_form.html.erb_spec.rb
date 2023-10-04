# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'bulkrax/exporters/_form', type: :view do
  let(:exporter) { Bulkrax::Exporter.new }
  let(:user) { create(:user) }

  let(:form) do
    view.simple_form_for exporter do |f|
      return f
    end
  end

  before do
    without_partial_double_verification do
      allow(view).to receive(:exporters_path).and_return('/')
    end
    render template: 'bulkrax/exporters/_form', locals: { exporter: exporter, form: form, current_user: user }
  end

  it 'renders a list of appropriate visibility options' do
    expect(rendered).to have_selector('option', text: 'University of Oregon')
  end
end
