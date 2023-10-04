# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'bulkrax/importers/_csv_fields', type: :view do
  let(:importer) { Bulkrax::Importer.new }
  let(:config) { Hyrax.config }
  let(:form) do
    view.simple_form_for importer do |f|
      return f
    end
  end

  before do
    without_partial_double_verification do
      allow(view).to receive(:importers_path).and_return('/')
    end
    # skip testing browse_everything here
    allow(Hyrax).to receive(:config).and_return(config)
    allow(config).to receive(:browse_everything?).and_return nil
    render template: 'bulkrax/importers/_csv_fields', locals: { importer: importer, fi: form }
  end

  it 'renders a list of appropriate visibility options' do
    expect(rendered).to have_selector('option', text: 'Oregon State University')
  end
end
