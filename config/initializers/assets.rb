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
Rails.application.config.assets.precompile += %w( plugins.js )
Rails.application.config.assets.precompile += %w( main.js )
Rails.application.config.assets.precompile += %w( dashboard.js )
Rails.application.config.assets.precompile += %w( widgets.js )
Rails.application.config.assets.precompile += %w( lib/vector-map/jquery.vmap.js )
Rails.application.config.assets.precompile += %w( lib/vector-map/jquery.vmap.min.js )
Rails.application.config.assets.precompile += %w( lib/vector-map/jquery.vmap.sampledata.js )
Rails.application.config.assets.precompile += %w( lib/vector-map/country/jquery.vmap.world.js )
Rails.application.config.assets.precompile += %w( normalize.css )
Rails.application.config.assets.precompile += %w( font-awesome.min.css )
Rails.application.config.assets.precompile += %w( flag-icon.min.css )
Rails.application.config.assets.precompile += %w( cs-skin-elastic.css )
Rails.application.config.assets.precompile += %w( style.css )
Rails.application.config.assets.precompile += %w( lib/vector-map/jqvmap.min.css )
Rails.application.config.assets.precompile += %w( xlsx.full.min.js )

