require 'spec_helper'

describe Webpack::Rails::Helper  do
  let(:source) { 'entry_point' }
  let(:asset_paths) { %w(/a/a.js /b/b.css) }

  include Webpack::Rails::Helper

  before do
    allow(Webpack::Rails::Manifest).to receive(:asset_paths).and_return(asset_paths)
  end

  describe '#webpack_asset_paths' do
    it "should return paths straight from te manifest if the dev server is disabled" do
      ::Rails.configuration.webpack.dev_server.enabled = false
      expect(webpack_asset_paths source).to eq(asset_paths)
    end

    it "should allow us to filter asset paths by extension" do
      ::Rails.configuration.webpack.dev_server.enabled = false
      expect(webpack_asset_paths(source, extension: 'js')).to eq(["/a/a.js"])
      expect(webpack_asset_paths(source, extension: 'css')).to eq(["/b/b.css"])
      expect(webpack_asset_paths(source, extension: 'html')).to eq([])
    end

    it "should have the user talk to the dev server if it's enabled for each path returned from the manifest defaulting to localhost" do
      ::Rails.configuration.webpack.dev_server.enabled = true
      ::Rails.configuration.webpack.dev_server.host = 'webpack.host'
      ::Rails.configuration.webpack.dev_server.port = 4000

      expect(webpack_asset_paths source).to eq([
        "http://webpack.host:4000/a/a.js", "http://webpack.host:4000/b/b.css"
      ])
    end

    it "should use https protocol when https is true" do
      ::Rails.configuration.webpack.dev_server.https = true
      expect(webpack_asset_paths(source, extension: 'js').first).to be_starts_with('https:')
    end

    it "should use http protocol when https is false" do
      ::Rails.configuration.webpack.dev_server.https = false
      expect(webpack_asset_paths(source, extension: 'js').first).to be_starts_with('http:')
    end

    it "should have the user talk to the specified dev server if it's enabled for each path returned from the manifest" do
      ::Rails.configuration.webpack.dev_server.enabled = true
      ::Rails.configuration.webpack.dev_server.port = 4000
      ::Rails.configuration.webpack.dev_server.host = 'webpack.host'

      expect(webpack_asset_paths source).to eq([
        "http://webpack.host:4000/a/a.js", "http://webpack.host:4000/b/b.css"
      ])
    end

    it "allows for the host to be evaluated at request time" do
      # Simulate the helper context
      request = double(:request, host: 'evaluated')

      ::Rails.configuration.webpack.dev_server.enabled = true
      ::Rails.configuration.webpack.dev_server.port = 4000
      ::Rails.configuration.webpack.dev_server.host = proc { request.host }

      expect(webpack_asset_paths source).to eq([
        "http://evaluated:4000/a/a.js", "http://evaluated:4000/b/b.css"
      ])
    end

    describe '#compute_asset_path' do
      let(:mock_parent_class) do
        Class.new do
          def compute_asset_path(source, _)
            source
          end
        end
      end
      let(:mock_class) do
        Class.new(mock_parent_class) { include Webpack::Rails::Helper }
      end
      let(:mock) { mock_class.new }

      before do
        ::Rails.configuration.webpack.dev_server.enabled = false
        ::Rails.configuration.webpack.dev_server.port = 4000
        ::Rails.configuration.webpack.dev_server.host = 'webpack.host'
      end

      subject { mock.compute_asset_path(source, options) }

      context 'when webpack asset exists' do
        context 'with js source' do
          let(:source) { 'a.js' }
          let(:options) { { type: :javascript } }
          it { is_expected.to eq('/a/a.js') }
        end
        context 'with css source' do
          let(:source) { 'b.css' }
          let(:options) { { type: :stylesheet } }
          it { is_expected.to eq('/b/b.css') }
        end
      end

      context 'when webpack asset do not exist' do
        before do
          allow(Webpack::Rails::Manifest).to receive(:asset_paths).and_raise(
            Webpack::Rails::Manifest::EntryPointMissingError
          )
          allow(self).to receive(:super).and_return('zzz.js')
        end
        let(:source) { 'zzz.js' }
        let(:options) { { type: :javascript } }
        it { is_expected.to eq('zzz.js') }
      end
    end
  end
end
