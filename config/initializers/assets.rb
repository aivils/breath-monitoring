# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile += %w( dygraph.js dygraph.css admin/graph.js )
Rails.application.config.assets.precompile += %w( active_admin.css bci.js)
Rails.application.config.assets.precompile += %w( beep.mp3 )
Rails.application.config.assets.precompile += %w( fonts/fa-brands-400.eot )
Rails.application.config.assets.precompile += %w( fonts/fa-brands-400.svg )
Rails.application.config.assets.precompile += %w( fonts/fa-brands-400.ttf )
Rails.application.config.assets.precompile += %w( fonts/fa-brands-400.woff )
Rails.application.config.assets.precompile += %w( fonts/fa-brands-400.woff2 )
Rails.application.config.assets.precompile += %w( fonts/fa-regular-400.eot )
Rails.application.config.assets.precompile += %w( fonts/fa-regular-400.svg )
Rails.application.config.assets.precompile += %w( fonts/fa-regular-400.ttf )
Rails.application.config.assets.precompile += %w( fonts/fa-regular-400.woff )
Rails.application.config.assets.precompile += %w( fonts/fa-regular-400.woff2 )
Rails.application.config.assets.precompile += %w( fonts/fa-solid-900.eot )
Rails.application.config.assets.precompile += %w( fonts/fa-solid-900.svg )
Rails.application.config.assets.precompile += %w( fonts/fa-solid-900.ttf )
Rails.application.config.assets.precompile += %w( fonts/fa-solid-900.woff )
Rails.application.config.assets.precompile += %w( fonts/fa-solid-900.woff2 )
