require 'webpack/rails/react_server_renderer'

# Watch our webpack files for changes in dev, so we can reload the JS VMs with the new JS code.

app = Rails.application
app.config.react.server_renderer = Webpack::Rails::ReactServerRenderer
app.config.watchable_files.concat Dir["#{app.root}/webpack/**/*"]
