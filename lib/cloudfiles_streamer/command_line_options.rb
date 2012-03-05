require 'optparse'
require 'ostruct'

module CloudFilesStreamer
  class MissingPrefixArgument < RuntimeError; end
  class InvalidByteCountArgument < RuntimeError; end
  class MissingCloudFilesContainer < RuntimeError; end
  class MissingCloudFilesUsername < RuntimeError; end
  class MissingCloudFilesApiKey < RuntimeError; end

  class CommandLineOptions
    DEFAULT_BYTE_COUNT = 4.5 * 1024 ** 3

    def self.parse(args = ARGV)
      args = %w{-h} if args.empty?
      options = parser(args)
      raise MissingPrefixArgument if options.prefix.empty?
      raise MissingCloudFilesContainer if options.container.empty?
      raise MissingCloudFilesUsername if options.cloudfiles_username.empty?
      raise MissingCloudFilesApiKey if options.cloudfiles_api_key.empty?
      options
    end

    def self.parser(args)
      options = OpenStruct.new
      options.prefix = ""
      options.container = ""
      options.cloudfiles_username = ENV['CLOUDFILES_USERNAME'].to_s
      options.cloudfiles_api_key = ENV['CLOUDFILES_API_KEY'].to_s
      options.byte_count = DEFAULT_BYTE_COUNT

      opts = OptionParser.new do |opts|
        opts.banner = "cloudfiles-streamer -p PREFIX -c CONTAINER"

        prefix_help = %{
          The base filename to name each segment, which will also be used to as
          the filename to download the entire chunk as when retrieving from
          CloudFiles. Example: `-p largefile.dump` will result in segments
          named `largefile.dump.000`, `largefile.dump.001`, etc and will
          downloadable from CloudFiles as one concatenated file as
          `largefile.dump`.
        }
        opts.on("-p PREFIX", "--prefix PREFIX", prefix_help) do |prefix|
          options.prefix = prefix.to_s.strip
        end

        container_help = %{
          Name of the CloudFiles container to upload to. The container will be
          created if it doesn't already exist.
        }
        opts.on("-c CONTAINER", container_help) do |name|
          options.container = name
        end

        opts.on("-u CLOUDFILES_USERNAME") do |name|
          options.cloudfiles_username = name
        end

        opts.on("-k CLOUDFILES_API_KEY") do |name|
          options.cloudfiles_api_key = name
        end

        segment_size_help = %{
          The maximum size of each segment in bytes or size spec (4k, 5m).
          Defaults to 4.5GB. The maximum size that CloudFiles will accept is
          5GB.
        }
        opts.on('-b SEGMENT_SIZE', segment_size_help) do |byte_count|
          options.byte_count = parse_byte_count(byte_count)
        end

        example = <<-EX
EXAMPLE USAGE

    cat some_large.dbdump | cloudfiles-streamer --prefix some_large.dbdump --container backups_container

        EX

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          print "\n", example
          exit
        end
      end
      opts.parse!(args)
      options
    end

    def self.parse_byte_count(byte_count_spec)
      matches    = byte_count_spec.match(/^(\d\.?\d*)(\w)?/)
      byte_count = matches[1].to_f
      units      = matches[2]
      return byte_count if byte_count > 0 && units.nil?
      return DEFAULT_BYTE_COUNT if byte_count.zero?

      case units
      when 'k'
        byte_count * 1024
      when 'm'
        byte_count * 1024 ** 2
      when 'g'
        byte_count * 1024 ** 3
      else
        raise InvalidByteCountArgument
      end
    end
  end
end
