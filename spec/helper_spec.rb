require 'spec_helper'

describe 'webpack_asset_paths' do
  let(:source) { 'entry_point' }
  let(:asset_paths) { %w(/a/a.js /b/b.js) }
  let(:request) { double }

  include Webpack::Rails::Helper

  before do
    expect(Webpack::Rails::Manifest).to receive(:asset_paths).with(source).and_return(asset_paths)
  end

  context 'with the dev server disabled' do
    before { ::Rails.configuration.webpack.dev_server.enabled = false }

    it 'should return paths straight from te manifest if the dev server is disabled' do
      expect(webpack_asset_paths source).to eq(asset_paths)
    end
  end

  context 'with the dev server enabled' do
    before { ::Rails.configuration.webpack.dev_server.enabled = true }

    it 'sets the manifest path the localhost by default' do
      ::Rails.configuration.webpack.dev_server.enabled = true
      ::Rails.configuration.webpack.dev_server.port = 4000

      expect(webpack_asset_paths source).to eq([
        '//localhost:4000/a/a.js', '//localhost:4000/b/b.js'
      ])
    end

    context 'with a specific server in the request' do
      let(:request) { double(host: 'webpack.host') }

      it 'sets the manifest path to the dev server host from the request' do
        ::Rails.configuration.webpack.dev_server.port = 4000
        ::Rails.configuration.webpack.dev_server.host = 'webpack.host'

        expect(webpack_asset_paths source).to eq([
          '//webpack.host:4000/a/a.js', '//webpack.host:4000/b/b.js'
        ])
      end
    end
  end
end
