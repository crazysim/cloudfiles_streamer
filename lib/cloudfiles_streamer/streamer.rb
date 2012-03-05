module CloudFilesStreamer
  class Streamer
	attr_reader :options, :segment_count, :container

	def initialize(options={}, fd = $stdin)
	  @segment_count = 0
	  @options   = options[:options] || CommandLineOptions.parse
	  @stream    = options[:stream]  || SegmentedStream.new(fd, @options.byte_count)
	end

	def call
	  CloudFilesApi.establish_connection(
		options.cloudfiles_username, options.cloudfiles_api_key)
	  @container = CloudFilesApi.get_or_create_container(options.container)
	  container.ensure_unique_prefix!(options.prefix)

	  while !@stream.eof?
		upload_segment
	  end

	  container.create_manifest(options.prefix, segment_count)
	end

	def upload_segment
	  container.create_object(segment_filename, @stream)
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
