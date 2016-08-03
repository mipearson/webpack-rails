module WebpackRailsReact
  # :nodoc:
  class ViewGenerator < ::Rails::Generators::Base
    source_root File.expand_path("../../../../example", __FILE__)

    desc "Generate a view with webpack entry / rails view / and webpack container"

    def normalize_view_name
      raise "View name argument missing" if args.length == 0
      @view = args[0]
    end

    def update_webpack_entry
      name = @view.downcase.gsub(/ /, "_")
      path = "'#{name}': './webpack/#{name}.js',"
      insert_into_file 'config/webpack.config.js', after: /entry: {\n/ do
        <<-CONFIG
    #{path}
        CONFIG
      end
    end

    def create_entry_file
      file = "webpack/#{@view.gsub(/ /, '')}.js"
      name = @view.titleize.gsub(/ /, '')
      copy_file "boilerplate/views/ViewTemplate.js", file
      gsub_file file, /Placeholder/, name
    end

    def create_container
      name = @view.titleize.gsub(/ /, '')
      file = "webpack/containers/#{name}.js"
      copy_file "boilerplate/views/ContainerTemplate.js", file
      gsub_file file, /Placeholder/, name
    end

    def create_rails_view
      name = @view.downcase.gsub(/ /, '_')
      empty_directory "app/views/#{name.pluralize}"
      file = "app/views/#{name.pluralize}/index.html.erb"
      copy_file "boilerplate/views/rails_view.html.erb", file
      gsub_file file, /placeholder/, name
    end
  end
end
