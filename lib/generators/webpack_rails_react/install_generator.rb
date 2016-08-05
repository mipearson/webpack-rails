module WebpackRailsReact
  # :nodoc:
  class InstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path("../../../../example", __FILE__)

    desc "Install everything you need for a basic webpack-rails integration"
    class_option :router, type: :boolean, default: false, description: 'Add React Router'
    class_option :redux, type: :boolean, default: false, description: 'Add Redux'

    def copy_package_json
      copy_file "package.json", "package.json"

      if options[:router]
        insert_into_file './package.json', after: /dependencies\": {\n/ do
          <<-'RUBY'
    "react-router": "^2.4.1",
          RUBY
        end
      end

      if options[:redux]
        insert_into_file './package.json', after: /dependencies\": {\n/ do
          <<-'RUBY'
    "react-redux": "^4.4.5",
    "redux": "^3.5.2",
    "redux-thunk": "^2.1.0",
          RUBY
        end
      end

      if options[:router] && options[:redux]
          insert_into_file './package.json', after: /dependencies\": {\n/ do
          <<-'RUBY'
    "react-router-redux": "^4.0.5",
          RUBY
         end
      end
    end

    def copy_webpack_conf
      copy_file "webpack.config.js", "config/webpack.config.js"
    end

    def create_webpack_application_js
      empty_directory "webpack"
      empty_directory "webpack/containers"
      empty_directory "webpack/components"

      if options[:router] && options[:redux]
        copy_file "boilerplate/router_redux/application.js", "webpack/application.js"
        copy_file "boilerplate/routes.js", "webpack/routes.js"
        copy_file "boilerplate/router_redux/store.js", "webpack/store.js"
        copy_file "boilerplate/router_redux/reducers.js", "webpack/reducers/index.js"
        create_file "webpack/actions.js"
        copy_file "boilerplate/router/App.js", "webpack/containers/App.js"
        copy_file "boilerplate/router/NoMatch.js", "webpack/components/NoMatch.js"
      elsif options[:router]
        copy_file "boilerplate/router/application.js", "webpack/application.js"
        copy_file "boilerplate/routes.js", "webpack/routes.js"
        copy_file "boilerplate/router/App.js", "webpack/containers/App.js"
        copy_file "boilerplate/router/NoMatch.js", "webpack/components/NoMatch.js"
      elsif options[:redux]
        copy_file "boilerplate/redux/application.js", "webpack/application.js"
        copy_file "boilerplate/redux/store.js", "webpack/store.js"
        copy_file "boilerplate/redux/reducers.js", "webpack/reducers/index.js"
        create_file "webpack/actions.js"
        copy_file "boilerplate/App.js", "webpack/containers/App.js"
      else
        copy_file "boilerplate/application.js", "webpack/application.js"
        copy_file "boilerplate/App.js", "webpack/containers/App.js"
      end

      haml_installed = Gem.loaded_specs.has_key? 'haml-rails'
      layouts_dir = 'app/views/layouts'

      application_view = haml_installed ? "#{layouts_dir}/application.html.haml" : "#{layouts_dir}/application.html.erb"

      if haml_installed
        # convert views to haml
        begin
          require 'html2haml'
        rescue LoadError
          `gem install html2haml`
        end
        `find . -name \*.erb -print | sed 'p;s/.erb$/.haml/' | xargs -n2 html2haml`
        `rm #{layouts_dir}/application.html.erb`

        insert_into_file application_view, before: /%body/ do
          <<-'RUBY'
    - if Rails.env.development?
      %script{:src => "http://localhost:3808/webpack-dev-server.js"}
          RUBY
        end

        insert_into_file application_view, after: /= yield/ do
            <<-'RUBY'

    = javascript_include_tag *webpack_asset_paths('application')
            RUBY
        end
      else
        insert_into_file application_view, before: /<\/head>/ do
          <<-'RUBY'
<% if Rails.env.development? %>
  <script src="http://localhost:3808/webpack-dev-server.js"></script>
<% end %>
          RUBY
        end

        insert_into_file application_view, before: /<\/body>/ do
          <<-'RUBY'
<%= javascript_include_tag *webpack_asset_paths('application') %>
          RUBY
        end
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

    def whats_next
      puts <<-EOF.strip_heredoc

        We've set up the basics of webpack-rails-react for you, but you'll still
        need to:

          1. Add an element with an id of 'app' to your layout
          2. To disable hot module replacement remove <script src="http://localhost:3808/webpack-dev-server.js"></script> from layout
          3. Run 'npm run dev_server' to run the webpack-dev-server
          4. Run 'bundle exec rails s' to run the rails server (both servers must be running)
          5. If you are using react-router and want to sync server routes add:
             get '*unmatched_route', to: <your client controller>#<default action>
             This must be the very last route in your routes.rb file
             e.g. get '*unmatched_route', to: 'home#index'

        See the README.md for this gem at
        https://github.com/cottonwoodcoding/webpack-rails-react/blob/master/README.md
        for more info.

        Thanks for using webpack-rails-react!

      EOF
    end
  end
end
