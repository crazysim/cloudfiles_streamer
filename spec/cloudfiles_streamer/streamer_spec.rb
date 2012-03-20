require 'cloudfiles_streamer/streamer'
require 'ostruct'

module CloudFilesStreamer
  class CommandLineOptions; end
  class SegmentedStream; end

  describe Streamer do
	let(:options) {
	  {
		:options => OpenStruct.new({ :prefix => "bob.dump" }),
		:stream => stub
	  }
	}

	it "parses command line options" do
	  CommandLineOptions.should_receive(:parse).and_return(stub)
	  Streamer.new(:stream => stub)
	end

	it "sets up a segmented stream" do
	  options = { :options => stub(:byte_count => 1024) }
	  stream = stub("IO object")
	  SegmentedStream.should_receive(:new).with(stream, 1024).and_return(stub)
	  Streamer.new(options, stream)
	end

	it "constructs segment filenames based on the current segment count" do
	  streamer = Streamer.new(options)
	  streamer.stub(:segment_count => 5)
	  streamer.segment_filename.should == "bob.dump.005"
	end

    it "creates the manifest" do
      container = double("CloudFiles container")
      streamer = Streamer.new(options)

      streamer.stub(
        :container => container,
        :segment_count => 42,
        :current_segment_filename => "bob.dump.042")

      container.should_receive(:create_manifest).
        with("bob.dump", "bob.dump.042", 42).once

      streamer.create_manifest
    end

	describe "keeps track of segments uploaded" do
	  it "starts at 0" do
		Streamer.new(options).segment_count.should == 0
	  end

	  it "increments by 1 after a successful upload" do
		container = double("CloudFiles container")
		container.should_receive(:create_object).and_return(true)
		streamer = Streamer.new(options)
		streamer.stub!(:container => container)

		expect { streamer.upload_segment }.to change { streamer.segment_count }.
		  from(0).to(1)
	  end
	end
  end
end
