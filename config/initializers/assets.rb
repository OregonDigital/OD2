# frozen_string_literal:true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('app/assets/html')
Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.precompile += %w( print.scss )
Rails.application.config.assets.precompile += %w( print.css )

# Add haml template parsing capabilities
Rails.application.config.assets.configure do |env|
  env.register_mime_type 'text/haml', extensions: ['.haml']
  env.register_transformer 'text/haml', 'text/html', Tilt::HamlTemplate
  env.register_engine '.haml', Tilt::HamlTemplate
end
