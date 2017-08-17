require 'react-rails'

# :nodoc:
module Webpack
  module Rails
    class ReactServerRenderer < React::ServerRendering::ExecJSRenderer
      # Actually a copy-paste of SprocketsRenderer with the entry point retrieval
      # changed.
      def initialize(options={})
        @replay_console = options.fetch(:replay_console, true)
        entry_points = options.fetch(:files, ["components"])
        js_code = CONSOLE_POLYFILL.dup

        entry_points.each do |entry_point|
          js_code << webpack_asset(entry_point)
        end

        super(options.merge(code: js_code))
      end

      def render(component_name, props, prerender_options)
        # pass prerender: :static to use renderToStaticMarkup
        react_render_method = if prerender_options == :static
            "renderToStaticMarkup"
          else
            "renderToString"
          end

        if !props.is_a?(String)
          props = props.to_json
        end

        super(component_name, props, {render_function: react_render_method})
      end

      def after_render(component_name, props, prerender_options)
        @replay_console ? CONSOLE_REPLAY : ""
      end

      # Reimplement console methods for replaying on the client
      CONSOLE_POLYFILL = <<-JS
        var console = { history: [] };
        ['error', 'log', 'info', 'warn'].forEach(function (fn) {
          console[fn] = function () {
            console.history.push({level: fn, arguments: Array.prototype.slice.call(arguments)});
          };
        });
      JS

      # Replay message from console history
      CONSOLE_REPLAY = <<-JS
        (function (history) {
          if (history && history.length > 0) {
            result += '\\n<scr'+'ipt>';
            history.forEach(function (msg) {
              result += '\\nconsole.' + msg.level + '.apply(console, ' + JSON.stringify(msg.arguments) + ');';
            });
            result += '\\n</scr'+'ipt>';
          }
        })(console.history);
      JS

      private

      def webpack_asset entry_point
        code = Webpack::Rails::Manifest.asset_paths(entry_point).map do |path|
          if ::Rails.configuration.webpack.dev_server.enabled
            webpack_asset_net(path)
          else
            webpack_asset_local(path)
          end
        end

        code.join("\n")
      end

      def webpack_asset_net path
        host = ::Rails.configuration.webpack.dev_server.host
        port = ::Rails.configuration.webpack.dev_server.port

        Net::HTTP.get(host, path, port)
      end

      def webpack_asset_local path
        File.read(
          Rails.root.join(
            ::Rails.configuration.webpack.output_dir,
            path
          )
        )
      end
    end
  end
end
