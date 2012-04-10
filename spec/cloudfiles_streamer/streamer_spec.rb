require 'cloudfiles_streamer/streamer'
require 'ostruct'

module CloudFilesStreamer
  class CommandLineOptions; end
  class SegmentedStream; end

  class CloudFilesApi
    class InvalidSession < RuntimeError; end
  end

  describe Streamer do
	let(:options) {
	  {
		:options => OpenStruct.new({
          :prefix => "bob.dump",
          :cloudfiles_username => "bob",
          :cloudfiles_api_key  => "bobsecret"
        }),
		:stream => stub
	  }
	}
    let(:io) { stub("IO object") }
    let(:container) { double("CloudFiles container") }

    subject { Streamer.new(options, io) }

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
	  subject.stub(:segment_count => 5)
	  subject.segment_filename.should == "bob.dump.005"
	end

    it "creates the manifest" do
      subject.stub(:container => container)

      container.should_receive(:create_manifest).with("bob.dump").once

      subject.create_manifest
    end

	describe "keeps track of segments uploaded" do
	  it "starts at 0" do
		subject.segment_count.should == 0
	  end

	  it "increments by 1 after a successful upload" do
		subject.stub(:container => container)
		container.should_receive(:create_object).and_return(true)

		expect { subject.upload_segment }.to change { subject.segment_count }.
		  from(0).to(1)
	  end
	end

    it "re-establishes the connection when CloudFiles API token expires and retries up to three times" do
      subject.stub(:container => container)
      CloudFilesApi.stub(:get_or_create_container => container)

      container.should_receive(:create_object).exactly(3).times.
        and_raise(CloudFilesApi::InvalidSession)
      CloudFilesApi.should_receive(:establish_connection).with("bob", "bobsecret").
        exactly(3).times

      expect {
        subject.upload_segment_with_retries
      }.to raise_error(MaxUploadAttemptsReached)
    end
  end
end
