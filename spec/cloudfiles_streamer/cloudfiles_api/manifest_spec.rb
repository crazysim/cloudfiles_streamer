require 'cloudfiles_streamer/cloudfiles_api/manifest'

class CloudFilesStreamer::CloudFilesApi

  describe Manifest do
    let(:prefix) { "bob.dump" }
    let(:container) { stub("CloudFiles Container", :name => "bobcontainer") }

    context "when more than one segment was uploaded" do
      it "creates the manifest object" do
        num_uploaded = 2
        manifest = double("CloudFiles Manifest Object")

        container.should_receive(:create_object).with(prefix).
          and_return(manifest)

        manifest.should_receive(:write).
          with("", { "X-Object-Manifest" => "bobcontainer/bob.dump" })

        Manifest.new(container, prefix, num_uploaded).create
      end
    end

    context "when only one segment was uploaded" do
      let(:object_name) { "bob.dump.000" }
      let(:num_uploaded) { 1 }

      it "renames the sole segment without a segment suffix" do
        cf_object = double("CloudFiles object")

        container.should_receive(:objects).with(:prefix => prefix).
          and_return([object_name])

        container.should_receive(:object).with(object_name).
          and_return(cf_object)

        cf_object.should_receive(:move).with(:name => prefix)
        Manifest.new(container, prefix, num_uploaded).create
      end

      context "when no objects with that prefix are found" do

        # MAX_RETRIES is currently set to 3 and we're not counting the first
        # try as a retry. Therefore, 3 retries plus the first try equals
        # exactly 4 calls.
        #
        it "backs off and retries up to 3 times" do
          container.should_receive(:objects).with(:prefix => prefix).
            exactly(4).times.and_return([])

          Kernel.should_receive(:sleep).exactly(4).times

          expect {
            Manifest.new(container, prefix, num_uploaded).create
          }.to raise_error(CloudFilesObjectMissing)
        end
      end
    end

  end
end
