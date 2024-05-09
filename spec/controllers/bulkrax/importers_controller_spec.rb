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
    allow(work).to receive(:all_errors).and_return({ dessert: ['no chocolate'] })
    allow(OregonDigital::VerifyWorkJob).to receive(:perform_later).and_return(true)
    allow(Sidekiq::Queue).to receive(:new).and_return(queue)
    allow(queue).to receive(:size).and_return(0)
  end

  describe '#work_ids' do
    before do
      controller.instance_variable_set(:@importer, importer)
    end

    it 'returns an array of hashes' do
      expect(controller.work_ids).to eq([{ entry_identifier: 'csv_entry', work_id: 'abcde1234' }])
    end
  end

  describe '#compile_errors' do
    context 'when the work exists' do
      before do
        controller.instance_variable_set(:@importer, importer)
      end

      it 'returns a hash of errors' do
        expect(controller.compile_errors).to eq({ 'abcde1234' => { dessert: ['no chocolate'] } })
      end
    end

    context 'when the work does not exist in solr' do
      before do
        controller.instance_variable_set(:@importer, importer)
        allow(Hyrax::SolrService).to receive(:query).and_return([])
      end

      it 'returns a hash with correct error' do
        expect(controller.compile_errors).to eq({ 'csv_entry' => 'Unable to load work for this entry.' })
      end
    end

    context 'when the work does not exist in valkyrie' do
      before do
        controller.instance_variable_set(:@importer, importer)
        allow(Hyrax.query_service).to receive(:find_by_alternate_identifier).and_raise(Valkyrie::Persistence::ObjectNotFoundError)
      end

      it 'returns a hash with correct error' do
        expect(controller.compile_errors).to eq({ 'abcde1234' => 'Unable to load work.' })
      end
    end
  end

  describe 'GET #show_errors' do
    it 'responds sucessfully' do
      get :show_errors, params: { importer_id: importer.id }
      expect(response).to be_successful
    end
  end

  describe 'GET #verify' do
    it 'displays notice and redirects' do
      get :verify, params: { importer_id: importer.id }
      expect(flash[:notice]).to eq('Verification jobs are enqueued. Jobs may be delayed depending on number/type of jobs already enqueued; please wait 5-10 minutes before checking results.')
      expect(response).to redirect_to importer_path(importer.id)
    end
  end
end
