# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bulkrax::ImportersController, type: :controller do
  routes { Bulkrax::Engine.routes }
  let(:valid_attributes) do
    {
      name: 'Test Importer',
      admin_set_id: 'admin_set/default',
      user_id: user.id,
      parser_klass: 'Bulkrax::CsvParser',
      parser_fields: { some_attribute: 'something' }
    }
  end
  let(:importer) { Bulkrax::Importer.create! valid_attributes }
  let(:entry) { build(:bulkrax_csv_entry_export, importerexporter: importer) }
  let(:work) { double }

  let(:role) { Role.create(name: 'admin') }
  let(:user) { create(:admin) }
  let(:queue) { double }

  controller do
    include OregonDigital::ImporterControllerBehavior
  end

  before do
    user.roles << role
    allow(controller.current_ability).to receive(:can_import_works?).with(any_args).and_return(true)
    sign_in user
    # copied from samvera/bulkrax
    # rubocop:disable RSpec/LeakyConstantDeclaration
    # rubocop:disable RSpec/InstanceVariable
    module Bulkrax::Auth
      def authenticate_user!
        @current_user = User.first
        true
      end

      def current_user
        @current_user
      end
    end
    # rubocop:enable RSpec/LeakyConstantDeclaration
    # rubocop:enable RSpec/InstanceVariable
    routes.draw do
      get '/importers/:importer_id/verify', to: 'bulkrax/importers#verify'
      get '/importers/:importer_id/show_errors', to: 'bulkrax/importers#show_errors'
    end
    described_class.prepend Bulkrax::Auth
    allow(Bulkrax::Importer).to receive(:find).and_return(importer)
    allow(importer).to receive(:entries).and_return([entry])
    allow(Hyrax::SolrService).to receive(:query).and_return([{ 'id' => 'abcde1234' }])
    allow(Hyrax.query_service).to receive(:find_by_alternate_identifier).and_return(work)
    allow(OregonDigital::VerifyWorkJob).to receive(:perform_later).and_return(true)
  end

  describe '#work_ids' do
    before do
      controller.instance_variable_set(:@importer, importer)
    end

    it 'returns an array of hashes' do
      expect(controller.work_ids).to eq([{ entry_identifier: 'csv_entry', work_id: 'abcde1234' }])
    end
  end

  describe 'GET #show_errors' do
    before do
      allow(controller).to receive(:report_path).and_return(fixture_path + '/batch_60_report_202404040930.json')
    end

    it 'responds sucessfully' do
      get :show_errors, params: { importer_id: importer.id, time: '202404040930' }
      expect(response).to be_successful
    end
  end

  describe 'GET #verify' do
    it 'displays notice and redirects' do
      get :verify, params: { importer_id: importer.id }
      expect(flash[:notice]).to eq('Verification jobs are enqueued. Jobs may be delayed depending on number/type of jobs already enqueued; an email will be sent to you when the report is complete.')
      expect(response).to redirect_to importer_path(importer.id)
    end
  end
end
