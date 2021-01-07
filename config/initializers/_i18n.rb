# frozen_string_literal:true

# Load application custom translations in order to use them in other initializers
I18n.load_path += Dir[Hyrax::Engine.root.join('config', 'locales', '*.{rb,yml}').to_s]
I18n.load_path += Dir[Blacklight::Engine.root.join('config', 'locales', '*.{rb,yml}').to_s]
I18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}').to_s]
