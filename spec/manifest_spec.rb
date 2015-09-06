require 'spec_helper'
require 'json'

describe "Webpack::Rails::Manifest" do
  let(:manifest) do
    <<-EOF
      {
        "assetsByChunkName": {
          "entry1": [ "entry1.js", "entry1-a.js" ],
          "entry2": "entry2.js"
        }
      }
    EOF
  end

  shared_examples_for "a valid manifest" do
    it "should return single entry asset paths from the manifest" do
      expect(Webpack::Rails::Manifest.asset_paths("entry2")).to eq(["/public_path/entry2.js"])
    end

    it "should return multiple entry asset paths from the manifest" do
      expect(Webpack::Rails::Manifest.asset_paths("entry1")).to eq(["/public_path/entry1.js", "/public_path/entry1-a.js"])
    end

    it "should error on a missing entry point" do
      expect { Webpack::Rails::Manifest.asset_paths("herp") }.to raise_error(Webpack::Rails::Manifest::EntryPointMissingError)
    end
  end

  before do
    # Test that config variables work while we're here
    ::Rails.configuration.webpack.dev_server.port = 2000
    ::Rails.configuration.webpack.manifest_filename = "my_manifest.json"
    ::Rails.configuration.webpack.public_path = "public_path"
    ::Rails.configuration.webpack.output_dir = "manifest_output"
  end

  context "with dev server enabled" do
    before do
      ::Rails.configuration.webpack.dev_server.enabled = true

      stub_request(:get, "http://localhost:2000/public_path/my_manifest.json").to_return(body: manifest, status: 200)
    end

    describe :asset_paths do
      it_should_behave_like "a valid manifest"

      it "should error if we can't find the manifest" do
        ::Rails.configuration.webpack.manifest_filename = "broken.json"
        stub_request(:get, "http://localhost:2000/public_path/broken.json").to_raise(SocketError)

        expect { Webpack::Rails::Manifest.asset_paths("entry1") }.to raise_error(Webpack::Rails::Manifest::ManifestLoadError)
      end
    end
  end

  context "with dev server disabled" do
    before do
      ::Rails.configuration.webpack.dev_server.enabled = false
      allow(File).to receive(:read).with(::Rails.root.join("manifest_output/my_manifest.json")).and_return(manifest)
    end

    describe :asset_paths do
      it_should_behave_like "a valid manifest"

      it "should error if we can't find the manifest" do
        ::Rails.configuration.webpack.manifest_filename = "broken.json"
        allow(File).to receive(:read).with(::Rails.root.join("manifest_output/broken.json")).and_raise(Errno::ENOENT)
        expect { Webpack::Rails::Manifest.asset_paths("entry1") }.to raise_error(Webpack::Rails::Manifest::ManifestLoadError)
      end
    end
  end
end
