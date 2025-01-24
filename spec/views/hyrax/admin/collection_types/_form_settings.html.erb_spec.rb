# frozen_string_literal: true

RSpec.describe 'hyrax/admin/collection_types/_form_settings.html.erb', type: :view do
  # TODO: add fields as they become available:
  # collection_type_assigns_workflow
  # collection_type_require_membership
  # collection_type_assigns_visibility

  let(:input_ids) do
    %w[collection_type_nestable
       collection_type_brandable
       collection_type_discoverable
       collection_type_sharable
       collection_type_share_applies_to_new_works
       collection_type_allow_multiple_membership
       collection_type_facet_configurable].freeze
  end
  let(:collection_type_form) { OregonDigital::Forms::Admin::CollectionTypeForm.new }
  let(:collection_type) { stub_model(Hyrax::CollectionType) }

  let(:form) do
    view.simple_form_for(collection_type, url: '/update') do |fs_form|
      return fs_form
    end
  end

  before do
    collection_type_form.collection_type = collection_type
    allow(form).to receive(:object).and_return(collection_type_form)
  end

  context 'when non-special collection types' do
    context 'when collection_type.collections? is false' do
      before do
        allow(collection_type).to receive(:collections).and_return([])
        render partial: 'hyrax/admin/collection_types/form_settings', locals: { f: form }
      end

      it 'renders the intructions and warning' do
        expect(rendered).to match(I18n.t('hyrax.admin.collection_types.form_settings.instructions'))
      end

      it 'renders the intructions and warning 2' do
        expect(rendered).to match(I18n.t('hyrax.admin.collection_types.form_settings.warning'))
      end

      it 'renders the checkbox to be enabled' do
        input_ids.each do |id|
          match = rendered.match(/(<input.*id="#{id}".*)/)
          expect(match[1].index('disabled="disabled"')).to be_nil
        end
      end

      it 'renders the checkbox to be enabled 2' do
        input_ids.each do |id|
          match = rendered.match(/(<input.*id="#{id}".*)/)
          expect(match).not_to be_nil
        end
      end
    end

    context 'when collection_type.collections? is true' do
      before do
        collection_type_form.collection_type = collection_type
        allow(collection_type_form).to receive(:collections?).and_return(true)
        assign(:form, collection_type_form)
        render partial: 'hyrax/admin/collection_types/form_settings', locals: { f: form }
      end

      it 'renders the checkbox to be disabled' do
        input_ids.each do |id|
          match = rendered.match(/(<input.*id="#{id}".*)/)
          expect(match[1].index('disabled="disabled"')).not_to be_nil
        end
      end

      it 'renders the checkbox to be disabled 2' do
        input_ids.each do |id|
          match = rendered.match(/(<input.*id="#{id}".*)/)
          expect(match).not_to be_nil
        end
      end
    end
  end

  context 'when all_settings_disabled? is true (admin_set or user collection type)' do
    before do
      allow(collection_type_form).to receive(:all_settings_disabled?).and_return(true)
      allow(collection_type).to receive(:collections).and_return([])
      render partial: 'hyrax/admin/collection_types/form_settings', locals: { f: form }
    end

    it 'renders the disabled checkbox' do
      input_ids.each do |id|
        match = rendered.match(/(<input.*id="#{id}".*)/)
        expect(match[1].index('disabled="disabled"')).not_to be_nil
      end
    end

    it 'renders the disabled checkbox 2' do
      input_ids.each do |id|
        match = rendered.match(/(<input.*id="#{id}".*)/)
        expect(match).not_to be_nil
      end
    end
  end
end
