require 'cloudfiles_streamer/cloudfiles_api'

module CloudFilesStreamer
  class CloudFilesApi::Container; end

  describe CloudFilesApi do
	it "can establish a connection to CloudFiles" do
	  connection = stub("CloudFiles connection")

	  CloudFiles::Connection.should_receive(:new).
		with(:username => "bob", :api_key => "secret").and_return(connection)

	  CloudFilesApi.establish_connection("bob", "secret")
	  CloudFilesApi.connection.should == connection
	end

	describe "requesting a container" do
	  let(:container)  { stub("CloudFiles container") }
	  let(:connection) { double("CloudFiles connection") }
	  let(:wrapped_container) { stub("ClouldFilesApi::Container") }

	  before do
		CloudFilesApi.stub(:connection => connection)
		CloudFilesApi::Container.should_receive(:new).with(container).
		  and_return(wrapped_container)
	  end

	  context "when the container exists" do
		it "returns the container" do
		  connection.should_receive(:container).with('bobcontainer').
			and_return(container)
		  found_container = CloudFilesApi.get_or_create_container('bobcontainer')
		  found_container.should == wrapped_container
		end
	  end

	  context "when the container does not exist" do
		it "creates a new container" do
		  connection.should_receive(:container).with('bobcontainer') {
			raise CloudFiles::Exception::NoSuchContainer }
		  connection.should_receive(:create_container).with('bobcontainer').
			and_return(container)

		  found_container = CloudFilesApi.get_or_create_container('bobcontainer')
		  found_container.should == wrapped_container
		end
	  end
	end
  end
end
