module CloudFilesStreamer
  class CloudFilesApi
    class PrefixNotUniqueError < RuntimeError; end
    class DuplicateObjectError < RuntimeError; end
    class InvalidSession < RuntimeError; end

    class Container
      def initialize(container, manifest_class = nil)
        @container = container
        @manifest_class ||= ::CloudFilesStreamer::CloudFilesApi::Manifest
      end

      def ensure_unique_prefix!(name)
        raise PrefixNotUniqueError if @container.object_exists?(name)
      end

      def create_manifest(prefix)
        @manifest_class.new(@container, prefix).create
      end

      def create_object(filename, file)
        if !@container.object_exists?(filename)
          object = @container.create_object(filename, false)
          object.write(file)
        else
          raise DuplicateObjectError,
            %{An object named "#{filename}" already exists in container "#{@container.name}"}
        end
      rescue ::CloudFiles::Exception::InvalidResponse => error
         raise InvalidSession if error.message =~ /response code 401\b/
      end
    end
  end
end
