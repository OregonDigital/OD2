# frozen_string_literal: true

#OVERRIDE FROM HYRAX
module Hyrax
  module WorkFormHelper
		##
		# @todo this implementation hits database backends (solr) and is invoked
		#   from views. refactor to avoid
		# @return  [Array<Array<String, String, Hash>] options for the admin set drop down.
		def admin_set_options
	  	return @admin_set_options.select_options if @admin_set_options

			service = Hyrax::AdminSetService.new(controller)
			Hyrax::AdminSetOptionsPresenter.new(service).select_options
		end

		def form_tabs_for(form:)
			if form.instance_of? Hyrax::Forms::BatchUploadForm
				%w[files metadata relationships]
			else
				%w[metadata files relationships]
			end
		end

		def form_tab_label_for(form:, tab:) # rubocop:disable Lint/UnusedMethodArgument
			t("hyrax.works.form.tab.#{tab}")
		end

		def form_progress_sections_for(*)
			[]
		end

		def form_file_set_select_for(parent:)
			return parent.select_files if parent.respond_to?(:select_files)
			return {} unless parent.respond_to?(:member_ids)

			file_sets =
				Hyrax::PcdmMemberPresenterFactory.new(parent, nil).file_set_presenters

			file_sets.each_with_object({}) do |presenter, hash|
				hash[presenter.title_or_label] = presenter.id
			end
		end
	end
end
