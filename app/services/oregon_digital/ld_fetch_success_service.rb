# frozen_string_literal:true

module OregonDigital
  # Message and Subject definitions for Linked Data fetching success notifications in Hyrax messaging service
  class LdFetchSuccessService < Hyrax::AbstractMessageService
    attr_reader :user, :uri
    def initialize(user, uri)
      @user = user
      @uri = uri
    end

    def message
      I18n.t(
        'oregon_digital.notifications.ld_fetch_success.message',
        uri: uri
      )
    end

    def subject
      I18n.t(
        'oregon_digital.notifications.ld_fetch_success.subject',
        uri: uri
      )
    end
  end
end
