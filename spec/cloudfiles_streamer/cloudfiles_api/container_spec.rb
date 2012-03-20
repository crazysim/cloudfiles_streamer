require 'cloudfiles_streamer/cloudfiles_api/container'

class InvalidResponseException < StandardError; end

module CloudFiles
  class Exception
    class InvalidResponse < InvalidResponseException; end
  end
end

class CloudFilesStreamer::CloudFilesApi
  describe Container do
	let(:cloudfiles_container) { double("CloudFiles container", :name => "bobcontainer") }

	subject { Container.new(cloudfiles_container) }

	describe "#ensure_unique_prefixi!" do
	  it "raises no error if the prefix is unique" do
		cloudfiles_container.should_receive(:object_exists?).and_return(false)
		expect { subject.ensure_unique_prefix!("bobcontainer") }.to_not raise_error
	  end

	  it "raises an error if the prefix is not unique" do
		cloudfiles_container.should_receive(:object_exists?).and_return(true)
		expect {
		  subject.ensure_unique_prefix!("bobcontainer")
		}.to raise_error(PrefixNotUniqueError)
	  end
	end

	describe "creating a manifest" do
      let(:prefix) { "bob.dump" }
      let(:current_object_name) { "bob.dump.001" }

	  context "when more than one segment was uploaded" do
		it "creates the manifest" do
		  manifest = double("CloudFiles Manifest Object")

		  cloudfiles_container.should_receive(:create_object).with(prefix).
            and_return(manifest)

		  manifest.should_receive(:write).
			with("", { "X-Object-Manifest" => "bobcontainer/bob.dump" })

		  subject.create_manifest(prefix, current_object_name, 2)
		end
	  end

	  context "when only one segment was uploaded" do
		it "renames the sole segment without a segment suffix" do
		  cf_object = double("CloudFiles object")

          cloudfiles_container.should_receive(:object).with(current_object_name).
            and_return(cf_object)

		  cf_object.should_receive(:move).with(:name => prefix)

		  subject.create_manifest(prefix, current_object_name, 1)
		end
	  end
	end

	describe "creating objects" do
	  let(:stream)   { double("IO stream") }
	  let(:filename) { "bob.dump.000" }

	  before do
		cloudfiles_container.stub(:object_exists? => false)
	  end

	  it "can create objects" do
		cf_object = double("CloudFiles object")

		cloudfiles_container.should_receive(:create_object).
		  with(filename, false).and_return(cf_object)
		cf_object.should_receive(:write).with(stream)

		subject.create_object(filename, stream)
	  end

	  it "raises an error if an object of the same name already exists" do
		cloudfiles_container.should_receive(:object_exists?).with(filename).
		  and_return(true)

		expect {
		  subject.create_object(filename, stream)
		}.to raise_error(DuplicateObjectError)
	  end

      it "raises InvalidSession if the session is expired" do
        exception = ::CloudFiles::Exception::InvalidResponse.new("Invalid response code 401")
		cloudfiles_container.should_receive(:object_exists?).with(filename).
          and_return(false)
        cloudfiles_container.should_receive(:create_object).and_raise(exception)

		expect {
		  subject.create_object(filename, stream)
		}.to raise_error(InvalidSession)
      end
	end
  end
end
