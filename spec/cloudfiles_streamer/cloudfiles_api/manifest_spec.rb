require 'cloudfiles_streamer/cloudfiles_api/manifest'

class CloudFilesStreamer::CloudFilesApi

  describe Manifest do
    let(:prefix) { "bob.dump" }
    let(:container) { stub("CloudFiles Container", :name => "bobcontainer") }

    it "creates the manifest object" do
      manifest = double("CloudFiles Manifest Object")

      container.should_receive(:create_object).with(prefix).
        and_return(manifest)

      manifest.should_receive(:write).
        with("", { "X-Object-Manifest" => "bobcontainer/bob.dump" })

      Manifest.new(container, prefix).create
    end

  end
end
