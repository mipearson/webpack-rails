module WebpackRails
  # :nodoc:
  class InstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path("../../../../example", __FILE__)

    desc "Install everything you need for a basic webpack-rails integration"

    def add_foreman_to_gemfile
      gem 'foreman'
    end

    def copy_procfile
      copy_file "Procfile", "Procfile"
    end

    def copy_package_json
      copy_file "package.json", "package.json"
    end

    def copy_webpack_conf
      copy_file "webpack.config.js", "config/webpack.config.js"
    end

    def create_webpack_application_js
      empty_directory "client"
      create_file "client/application.js" do
        <<-EOF.strip_heredoc
        import React from 'react';
        import ReactDOM from 'react-dom';
        import App from './App';

        ReactDOM.render(
          <App />,
          Document.findElementById('app')
        )
        EOF
      end

      create_file "client/App.js" do
        <<-EOF.strip_heredoc
          import React from 'react';

          class App extends React.Component {
            render() {
              return(
                <div>
                  Hello World
                </div>
              )
            }
          }

          export default App;
        EOF
      end
    end

    def add_to_gitignore
      append_to_file ".gitignore" do
        <<-EOF.strip_heredoc
        # Added by webpack-rails
        /node_modules
        /public/webpack
        EOF
      end
    end

    def run_npm_install
      run "npm install" if yes?("Would you like us to run 'npm install' for you?")
    end

    def run_bundle_install
      run "bundle install" if yes?("Would you like us to run 'bundle install' for you?")
    end

    def whats_next
      puts <<-EOF.strip_heredoc

        We've set up the basics of webpack-rails for you, but you'll still
        need to:

          1. Add the 'application' entry point in to your layout, and
            e.g. <%= javascript_include_tag *webpack_asset_paths('application') %>
          2. Add an element with an id of 'app' do your layout
          3. Enable hot module replacement by adding <script src="http://localhost:3808/webpack-dev-server.js"></script> to your layout
          4. Run 'foreman start' to run the webpack-dev-server and rails server

          Example app/views/layouts/application.html.erb
          <!DOCTYPE html>
          <html>
            <head>
              <title>WebpackDemo</title>
              <%= stylesheet_link_tag    'application', media: 'all' %>
              <%= javascript_include_tag 'application' %>
              <script src="http://localhost:3808/webpack-dev-server.js"></script>
              <%= csrf_meta_tags %>
            </head>
            <body>

              <%= yield %>
              <%= javascript_include_tag *webpack_asset_paths('application') %>
            </body>
          </html>


        See the README.md for this gem at
        https://github.com/wdjungst/webpack-rails-react/blob/master/README.md
        for more info.

        Thanks for using webpack-rails-react!

      EOF
    end
  end
end
