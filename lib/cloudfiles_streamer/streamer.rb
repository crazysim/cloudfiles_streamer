module CloudFilesStreamer
  class MaxUploadAttemptsReached < RuntimeError; end

  class Streamer
    MAX_SEGMENT_UPLOAD_ATTEMPTS = 3

	attr_reader :options, :segment_count, :container, :current_segment_filename

    def initialize(options={}, fd = $stdin)
      @segment_count = 0
      @options   = options[:options] || CommandLineOptions.parse
      @stream    = options[:stream]  || SegmentedStream.new(fd, @options.byte_count)
    end

    def call
      establish_connection
      container.ensure_unique_prefix!(options.prefix)

      while !@stream.eof?
        upload_segment_with_retries
      end

      create_manifest
	end

    def establish_connection
      CloudFilesApi.establish_connection(
        options.cloudfiles_username, options.cloudfiles_api_key)
      @container = CloudFilesApi.get_or_create_container(options.container)
    end

    def create_manifest
	  container.create_manifest(options.prefix, current_segment_filename, segment_count)
    end

    def upload_segment_with_retries
      tries = 0
      begin
        tries += 1
        upload_segment
      rescue CloudFilesApi::InvalidSession
        establish_connection
        if tries < MAX_SEGMENT_UPLOAD_ATTEMPTS
          retry
        else
          raise MaxUploadAttemptsReached
        end
      end
    end

	def upload_segment
      @current_segment_filename = segment_filename
	  container.create_object(@current_segment_filename, @stream)
	  increment_segment_count
	end

    def segment_filename
      options.prefix + "." + segment_count.to_s.rjust(3, '0')
    end

    def increment_segment_count
      @segment_count += 1
    end
  end
end
