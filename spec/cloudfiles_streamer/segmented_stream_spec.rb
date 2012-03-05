require 'cloudfiles_streamer/segmented_stream'

module CloudFilesStreamer
  describe SegmentedStream do
    subject { SegmentedStream }

    let(:stdin) { stub("stub IO object") }

    it "wraps an IO-like object as a file" do
      subject.new(stdin, stub).file.should == stdin
    end

    it "knows the configured segment size in bytes" do
      subject.new(stdin, 1024).segment_size.should == 1024
    end

    it "delegates #eof? to the wrapped IO object" do
      stdin = mock
      stdin.should_receive(:eof?).once
      subject.new(stdin, stub).eof?
    end

    it "delegates #eof! to the wrapped IO object" do
      stdin = mock
      stdin.should_receive(:eof!).once
      subject.new(stdin, stub).eof!
    end

    describe "#read" do
      let(:stdin) { mock }
      let(:segment_size) { 1024 }
      let(:stream) { subject.new(stdin, segment_size) }

      context "when the segment size limit has not been reached" do
        before do
          stream.stub(:segment_limit_reached? => false)
        end

        it "delegates to the the wrapped IO object" do
          stdin.should_receive(:read).with(512).once.and_return("")
          stream.read(512)
        end

        it "reads no more than segment_size length at a time" do
          stdin.should_receive(:read).with(segment_size).once.and_return("")
          stream.read(2048)
        end

        it "returns the contents read" do
          buffer = stub(:length => 1)
          stdin.stub!(:read => buffer)
          stream.read(512).should == buffer
        end

        context "when bytes are read" do
          let(:buffer) { stub(:length => 512) }
          before do
            stdin.stub!(:read => buffer)
          end

          it "increments the bytes_read counter" do
            expect {
              2.times { stream.read(512) }
            }.to change { stream.bytes_read }.by(1024)
          end

          it "increments the total_bytes_read counter" do
            expect {
              2.times { stream.read(512) }
            }.to change { stream.total_bytes_read }.by(1024)
          end
        end

        context "when no bytes are read" do
          before do
            stdin.stub!(:read => nil)
          end

          it "does not increment the bytes_read counter" do
            expect { stream.read(512) }.not_to change { stream.bytes_read }
          end

          it "does not increment the total_bytes_read counter" do
            expect { stream.read(512) }.not_to change { stream.total_bytes_read }
          end
        end
      end

      context "when the segment size limit is reached or exceeded" do
        before do
          stream.stub(:segment_limit_reached? => true)
        end

        it "does not read from the IO object" do
          stdin.should_receive(:read).never
          stream.read(512)
        end

        it "resets bytes_read counter to 0" do
          stream.read(512)
          stream.bytes_read.should == 0
        end

        it "does not increment the total_bytes_read counter" do
          expect { stream.read(512) }.not_to change { stream.total_bytes_read }
        end

        it "returns nil" do
          stream.read(512).should be_nil
        end
      end
    end

    describe "#segment_limit_reached?" do
      let(:segment_size) { 1024 }
      let(:stream) { subject.new(stub, segment_size) }

      it "is true when the limit is reached exactly" do
        stream.stub(:bytes_read => segment_size)
        stream.segment_limit_reached?.should be_true
      end

      it "is true when the limit is exceeded" do
        stream.stub(:bytes_read => segment_size + 1)
        stream.segment_limit_reached?.should be_true
      end

      it "is false when the limit has not been reached" do
        stream.stub(:bytes_read => 1)
        stream.segment_limit_reached?.should be_false
      end
    end
  end
end
