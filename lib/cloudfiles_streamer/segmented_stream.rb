module CloudFilesStreamer
  class SegmentedStream
    attr_reader :file, :segment_size, :bytes_read, :total_bytes_read

    def initialize(data, segment_size)
      @file = data
      @segment_size = segment_size
      @bytes_read = 0
      @total_bytes_read = 0
    end

    def read(length)
      reset_bytes_read! and return if segment_limit_reached?
      buffer = file.read(size_up_to_limit(length))
      increment_counters(buffer.length) if !buffer.nil?
      buffer
    end

    def segment_limit_reached?
      bytes_read >= segment_size
    end

    def eof?
      file.eof?
    end

    def eof!
      file.eof!
    end

    private
    def size_up_to_limit(length)
      segment_size > length ? length : segment_size
    end

    def increment_counters(delta)
      @bytes_read += delta
      @total_bytes_read += delta
    end

    def reset_bytes_read!
      @bytes_read = 0
    end
  end
end
