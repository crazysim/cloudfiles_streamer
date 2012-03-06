module CloudFilesStreamer
  class CloudFilesApi
    class PrefixNotUniqueError < RuntimeError; end
    class DuplicateObjectError < RuntimeError; end

    class Container
      def initialize(container)
        @container = container
      end

      def ensure_unique_prefix!(name)
        raise PrefixNotUniqueError if @container.object_exists?(name)
      end

      def create_manifest(prefix, num_uploaded_segments)
        if num_uploaded_segments > 1
          manifest = @container.create_object(prefix)
          manifest.write("", "X-Object-Manifest" => "#{@container.name}/#{prefix}")
        else
          object_name = @container.objects(:prefix => prefix, :limit => 1).first
          object = @container.object(object_name)
          object.move(:name => prefix)
        end
      end

      def create_object(filename, file)
        if !@container.object_exists?(filename)
          object = @container.create_object(filename, false)
          object.write(file)
        else
          raise DuplicateObjectError,
            %{An object named "#{filename}" already exists in container "#{@container.name}"}
        end
      end
    end
  end
end
