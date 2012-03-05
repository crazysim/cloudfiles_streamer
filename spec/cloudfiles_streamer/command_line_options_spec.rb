require 'cloudfiles_streamer/command_line_options'

module CloudFilesStreamer
  describe CommandLineOptions do
    subject { CommandLineOptions }

    let(:default_byte_count) { 4.5 * 1024 ** 3 }

    it "requires a prefix" do
      expect { subject.parse(%w{-c container}) }.to raise_error(MissingPrefixArgument)
    end

    it "defaults to 4.5GB byte count" do
      valid_arguments = %w{--prefix myprefix -c mycontainer -u bob -k secret}
      options = subject.parse(valid_arguments)
      options.byte_count.should == default_byte_count
    end

    describe "#parse_byte_count" do
      it "defaults to default byte count if the byte count is 0" do
        subject.parse_byte_count("0").should == default_byte_count
      end

      it "accepts byte counts" do
        subject.parse_byte_count("1024").should == 1024.0
      end

      it "accepts byte counts in kBs" do
        subject.parse_byte_count("4k").should == (4 * 1024).to_f
      end

      it "accepts byte counts in MBs" do
        subject.parse_byte_count("5.5m").should == (5.5 * 1024 ** 2).to_f
      end

      it "accepts byte counts in GBs" do
        subject.parse_byte_count("4g").should == (4 * 1024 ** 3).to_f
      end

      it "aborts when not using an acceptable unit" do
        expect {
          subject.parse_byte_count("4z")
        }.to raise_error(InvalidByteCountArgument)
      end
    end

    it "accepts the name of a CloudFiles container" do
      options = subject.parse(%w{--prefix myprefix -c mycontainer -u bob -k secret})
      options.container.should == 'mycontainer'
    end

    it "requires a container to be specified" do
      expect {
        subject.parse(%w{--prefix myprefix})
      }.to raise_error(MissingCloudFilesContainer)
    end

    describe "credentials" do
      it "accepts a CloudFiles username option" do
        options = subject.parse(%w{--prefix myprefix -c mycontainer -u bob -k secret})
        options.cloudfiles_username.should == 'bob'
      end

      it "requires a CloudFiles username" do
        expect {
          subject.parse(%w{--prefix myprefix -c mycontainer})
        }.to raise_error(MissingCloudFilesUsername)
      end

      it "accepts a CloudFiles API key" do
        options = subject.parse(%w{--prefix myprefix -c mycontainer -u bob -k secret})
        options.cloudfiles_api_key.should == 'secret'
      end

      it "requires a CloudFiles API key" do
        expect {
          subject.parse(%w{--prefix myprefix -c mycontainer -u bob})
        }.to raise_error(MissingCloudFilesApiKey)
      end

      it "accepts a CloudFiles username as an ENV variable" do
        ENV['CLOUDFILES_USERNAME'] = 'alice'
        options = subject.parse(%w{--prefix myprefix -c mycontainer -k secret})
        options.cloudfiles_username.should == 'alice'
      end

      it "accepts a CloudFiles API key as an ENV variable" do
        ENV['CLOUDFILES_API_KEY'] = 'super-secret'
        options = subject.parse(%w{--prefix myprefix -c mycontainer -u bob})
        options.cloudfiles_api_key.should == 'super-secret'
      end
    end
  end
end
