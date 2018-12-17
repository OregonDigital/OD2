module OregonDigital
  class OembedErrorService < Hyrax::AbstractMessageService
    attr_reader :user, :messages
    def initialize(user, messages)
      @user = user
      @messages = messages.to_sentence
    end

    def message
      I18n.t('oregon_digital.notifications.oembed_error.message', messages: messages)
    end

    def subject
      I18n.t('oregon_digital.notifications.oembed_error.subject')
    end
  end
end
