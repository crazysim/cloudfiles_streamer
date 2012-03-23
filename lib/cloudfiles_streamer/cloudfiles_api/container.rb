module CloudFilesStreamer
  class CloudFilesApi
    class PrefixNotUniqueError < RuntimeError; end
    class DuplicateObjectError < RuntimeError; end
    class InvalidSession < RuntimeError; end

    class Container
      def initialize(container)
        @container = container
      end

      def ensure_unique_prefix!(name)
        raise PrefixNotUniqueError if @container.object_exists?(name)
      end

      def create_manifest(prefix, num_uploaded)
        Manifest.new(@container, prefix, num_uploaded).create
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
