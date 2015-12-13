module WebpackRails
  # :nodoc:
  class InstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path("../../../../example", __FILE__)

    desc "Install everything you need for a basic webpack-rails integration"

    def use_react
      @using_react if yes?("Will you be using react?")
    end

    def add_foreman_to_gemfile
      gem 'foreman'
    end

    def copy_procfile
      copy_file "Procfile", "Procfile"
    end

    def copy_package_json
      src = @using_react ? "package-react.json" : "package.json"
      copy_file src, "package.json"
    end

    def copy_webpack_conf
      src = @using_react ? "webpack-react.config.js" : "webpack.config.js"

      copy_file "webpack.config.js", "config/webpack.config.js"
    end

    def copy_react_initializer
      return unless @using_react
      copy_file "react_initializer.rb", "config/initializers/webpack-rails-react.rb"
    end

    def create_webpack_application_js
      empty_directory "webpack"
      content = <<-EOF.strip_heredoc
        console.log("Hello world!");
      EOF
      if @using_react
        content += "require('./react_ujs');\n"
      end

      create_file "webpack/application.js", { content }
    end

    def copy_react_ujs
      return unless @using_react
      copy_file "react_ujs.js", "webpack/react_ujs.js"
    end

    def create_webpack_components_js
      return unless @using_react
      create_file "webpack/components.js" do
        <<-EOF.strip_heredoc
        // This entry point is used by react-rails to render components on the server side.

        require('expose?React!react');
        require('expose?ReactDOMServer!react-dom/server');
        // Expose each component here
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
          2. Run 'foreman start' to run the webpack-dev-server and rails server

        See the README.md for this gem at
        https://github.com/mipearson/webpack-rails/blob/master/README.md
        for more info.

        Thanks for using webpack-rails!

      EOF
    end

    def react_notes
      return unless @using_react

      puts <<-EOF.strip_heredoc

        *** REACT ***

        As you've chosen to use the webpack-rails react-rails integration, we've
        replaced the default react-rails SprocketsRenderer with our own
        WebpackRenderer in config/initializers/webpack-rails-react.rb

      EOF
  end
end
