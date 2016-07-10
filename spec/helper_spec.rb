require 'spec_helper'

describe 'webpack_asset_paths' do
  let(:source) { 'entry_point' }
  let(:asset_paths) { %w(/a/a.js /b/b.css) }

  include Webpack::Rails::Helper

  before do
    allow(Webpack::Rails::Manifest).to receive(:asset_paths).with(source).and_return(asset_paths)
  end

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
    ::Rails.configuration.webpack.dev_server.port = 4000

    expect(webpack_asset_paths source).to eq([
      "http://localhost:4000/a/a.js", "http://localhost:4000/b/b.css"
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
end
