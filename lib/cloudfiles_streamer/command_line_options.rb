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
        opts.on("-p PREFIX", "--prefix PREFIX") do |prefix|
          options.prefix = prefix.to_s.strip
        end

        opts.on("-c CONTAINER") do |name|
          options.container = name
        end

        opts.on("-u CLOUDFILES_USERNAME") do |name|
          options.cloudfiles_username = name
        end

        opts.on("-p CLOUDFILES_API_KEY") do |name|
          options.cloudfiles_api_key = name
        end

        opts.on('-b BYTE_COUNT') do |byte_count|
          options.byte_count = parse_byte_count(byte_count)
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
