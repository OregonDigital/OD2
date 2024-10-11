# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'bulkrax/importers/_csv_fields', type: :view do
  let(:importer) { Bulkrax::Importer.new }
  let(:config) { Hyrax.config }
  # actionview checks entry_statuses against the importer class and blows up
  # but only here in the test environment. since we're not here to test that
  # skip the problem for now by using option in simple_form_for
  let(:form) do
    view.simple_form_for importer, allow_method_names_outside_object: true do |f|
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
