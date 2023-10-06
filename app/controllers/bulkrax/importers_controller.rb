# frozen_string_literal: true

require_dependency 'bulkrax/application_controller'
require_dependency 'oai'

# OVERRIDE: Override controller to add in new method for download
module Bulkrax
  # rubocop:disable Metrics/ClassLength
  class ImportersController < ApplicationController
    include Hyrax::ThemedLayoutController if defined?(::Hyrax)
    include Bulkrax::DownloadBehavior
    include Bulkrax::API
    include Bulkrax::ValidationHelper

    protect_from_forgery unless: -> { api_request? }
    before_action :token_authenticate!, if: -> { api_request? }, only: [:create, :update, :delete]
    before_action :authenticate_user!, unless: -> { api_request? }
    before_action :check_permissions
    before_action :set_importer, only: [:show, :edit, :update, :destroy]
    with_themed_layout 'dashboard' if defined?(::Hyrax)

    # GET /importers
    def index
      # NOTE: We're paginating this in the browser.
      @importers = Importer.order(created_at: :desc).all
      if api_request?
        json_response('index')
      elsif defined?(::Hyrax)
        add_importer_breadcrumbs
      end
    end

    # GET /importers/1
    def show
      if api_request?
        json_response('show')
      elsif defined?(::Hyrax)
        add_importer_breadcrumbs
        add_breadcrumb @importer.name
      end
      @work_entries = @importer.entries.where(type: @importer.parser.entry_class.to_s).page(params[:work_entries_page]).per(30)
      @collection_entries = @importer.entries.where(type: @importer.parser.collection_entry_class.to_s).page(params[:collections_entries_page]).per(30)
      @file_set_entries = @importer.entries.where(type: @importer.parser.file_set_entry_class.to_s).page(params[:file_set_entries_page]).per(30)
    end

    # GET /importers/new
    def new
      @importer = Importer.new
      if api_request?
        json_response('new')
      elsif defined?(::Hyrax)
        add_importer_breadcrumbs
        add_breadcrumb 'New'
      end
    end

    # GET /importers/1/edit
    def edit
      if api_request?
        json_response('edit')
      elsif defined?(::Hyrax)
        add_importer_breadcrumbs
        add_breadcrumb @importer.name, bulkrax.importer_path(@importer.id)
        add_breadcrumb 'Edit'
      end
    end

    # POST /importers
    # rubocop:disable Metrics/MethodLength
    def create
      # rubocop:disable Style/IfInsideElse
      if api_request?
        return return_json_response unless valid_create_params?
      end
      file = file_param
      cloud_files = cloud_params

      @importer = Importer.new(importer_params)
      field_mapping_params
      @importer.validate_only = true if params[:commit] == 'Create and Validate'
      # the following line is needed to handle updating remote files of a FileSet
      # on a new import otherwise it only gets updated during the update path
      @importer.parser_fields['update_files'] = true if params[:commit] == 'Create and Import'
      if @importer.save
        files_for_import(file, cloud_files)
        if params[:commit] == 'Create and Import'
          Bulkrax::ImporterJob.send(@importer.parser.perform_method, @importer.id)
          render_request('Importer was successfully created and import has been queued.')
        elsif params[:commit] == 'Create and Validate'
          Bulkrax::ImporterJob.send(@importer.parser.perform_method, @importer.id)
          render_request('Importer validation completed. Please review and choose to either Continue with or Discard the import.', true)
        else
          render_request('Importer was successfully created.')
        end
      else
        if api_request?
          json_response('create', :unprocessable_entity)
        else
          render :new
        end
      end
      # rubocop:enable Style/IfInsideElse
    end

    # PATCH/PUT /importers/1
    # # @todo refactor so as to not need to disable rubocop
    # rubocop:disable all
    def update
      if api_request?
        return return_json_response unless valid_update_params?
      end

      file = file_param
      cloud_files = cloud_params

      # Skipped during a continue
      field_mapping_params if params[:importer][:parser_fields].present?

      if @importer.update(importer_params)
        files_for_import(file, cloud_files) unless file.nil? && cloud_files.nil?
        # do not perform the import
        unless params[:commit] == 'Update Importer'
          set_files_parser_fields
          Bulkrax::ImporterJob.send(@importer.parser.perform_method, @importer.id, update_harvest)
        end
        if api_request?
          json_response('updated', :ok, 'Importer was successfully updated.')
        else
          redirect_to importers_path, notice: 'Importer was successfully updated.'
        end
      else
        if api_request?
          json_response('update', :unprocessable_entity, 'Something went wrong.')
        else
          render :edit
        end
      end
    end
    # rubocop:enable all
    # rubocop:enable Metrics/MethodLength

    # DELETE /importers/1
    def destroy
      @importer.destroy
      if api_request?
        json_response('destroy', :ok, notice: 'Importer was successfully destroyed.')
      else
        redirect_to importers_url, notice: 'Importer was successfully destroyed.'
      end
    end

    # PUT /importers/1
    def continue
      @importer = Importer.find(params[:importer_id])
      params[:importer] = { name: @importer.name }
      @importer.validate_only = false
      update
    end

    # GET /importer/1/upload_corrected_entries
    def upload_corrected_entries
      @importer = Importer.find(params[:importer_id])
      return unless defined?(::Hyrax)
      add_breadcrumb t(:'hyrax.controls.home'), main_app.root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb 'Importers', bulkrax.importers_path
      add_breadcrumb @importer.name, bulkrax.importer_path(@importer.id)
      add_breadcrumb 'Upload Corrected Entries'
    end

    # POST /importer/1/upload_corrected_entries_file
    def upload_corrected_entries_file
      file = params[:importer][:parser_fields].delete(:file)
      @importer = Importer.find(params[:importer_id])
      if file.present?
        @importer[:parser_fields]['partial_import_file_path'] = @importer.parser.write_partial_import_file(file)
        @importer.save
        Bulkrax::ImporterJob.perform_later(@importer.id, true)
        redirect_to importer_path(@importer), notice: 'Corrected entries uploaded successfully.'
      else
        redirect_to importer_upload_corrected_entries_path(@importer), alert: 'Importer failed to update with new file.'
      end
    end

    def external_sets
      if list_external_sets
        render json: { base_url: params[:base_url], sets: @sets }
      else
        render json: { base_url: params[:base_url], error: "unable to pull data from #{params[:base_url]}" }
      end
    end

    # GET /importers/1/export_errors
    def export_errors
      @importer = Importer.find(params[:importer_id])
      @importer.write_errored_entries_file
      send_content
    end

     # GET /importers/1/download
    def download
      @importer = Importer.find(params[:importer_id])
      send_file(params[:url])
    end

    private

    def files_for_import(file, cloud_files)
      return if file.blank? && cloud_files.blank?
      @importer[:parser_fields]['import_file_path'] = @importer.parser.write_import_file(file) if file.present?
      if cloud_files.present?
        # For BagIt, there will only be one bag, so we get the file_path back and set import_file_path
        # For CSV, we expect only file uploads, so we won't get the file_path back
        # and we expect the import_file_path to be set already
        target = @importer.parser.retrieve_cloud_files(cloud_files)
        @importer[:parser_fields]['import_file_path'] = target if target.present?
      end
      @importer.save
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_importer
      @importer = Importer.find(params[:id])
    end

    def importable_params
      params.except(:selected_files)
    end

    def importable_parser_fields
      params&.[](:importer)&.[](:parser_fields)&.except(:file)&.keys
    end

    # Only allow a trusted parameters through.
    def importer_params
      importable_params.require(:importer).permit(
        :name,
        :admin_set_id,
        :user_id,
        :frequency,
        :parser_klass,
        :limit,
        :validate_only,
        selected_files: {},
        field_mapping: {},
        parser_fields: [importable_parser_fields]
      )
    end

    def list_external_sets
      url = params[:base_url] || (@harvester ? @harvester.base_url : nil)
      setup_client(url) if url.present?

      @sets = [['All', 'all']]

      begin
        @client.list_sets.each do |s|
          @sets << [s.name, s.spec]
        end
      rescue
        return false
      end

      @sets
    end

    def file_param
      params.require(:importer).require(:parser_fields).fetch(:file) if params&.[](:importer)&.[](:parser_fields)&.[](:file)
    end

    def cloud_params
      params.permit(selected_files: {}).fetch(:selected_files).to_h if params&.[](:selected_files)
    end

    # Add the field_mapping from the Bulkrax configuration
    def field_mapping_params
      # @todo replace/append once mapping GUI is in place
      field_mapping_key = Bulkrax.parsers.map { |m| m[:class_name] if m[:class_name] == params[:importer][:parser_klass] }.compact.first
      @importer.field_mapping = Bulkrax.field_mappings[field_mapping_key] if field_mapping_key
    end

    def add_importer_breadcrumbs
      add_breadcrumb t(:'hyrax.controls.home'), main_app.root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb 'Importers', bulkrax.importers_path
    end

    def setup_client(url)
      return false if url.nil?
      headers = { from: Bulkrax.server_name }
      @client ||= OAI::Client.new(url, headers: headers, parser: 'libxml')
    end

    # Download methods

    def file_path
      @importer.errored_entries_csv_path
    end

    def download_content_type
      'text/csv'
    end

    def render_request(message, validate_only = false)
      if api_request?
        json_response('create', :created, message)
      else
        path = validate_only ? importer_path(@importer) : importers_path
        redirect_to path, notice: message
      end
    end

    # update methods (for commit deciphering)
    def update_harvest
      # OAI-only - selective re-harvest
      params[:commit] == 'Update and Harvest Updated Items'
    end

    def set_files_parser_fields
      if params[:commit] == 'Update Metadata and Files'
        @importer.parser_fields['update_files'] = true
      elsif params[:commit] == ('Update and Replace Files' || 'Update and Re-Harvest All Items')
        @importer.parser_fields['replace_files'] = true
      elsif params[:commit] == 'Update and Harvest Updated Items'
        return
      else
        @importer.parser_fields['metadata_only'] = true
      end
      @importer.save
    end

    def check_permissions
      raise CanCan::AccessDenied unless current_ability.can_import_works?
    end
  end
  # rubocop:enable Metrics/ClassLength
end
