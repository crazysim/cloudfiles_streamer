module CloudFilesStreamer
  class CloudFilesApi
    class Manifest
      def initialize(container, prefix)
        @container = container
        @prefix = prefix
      end

      def create
        manifest = @container.create_object(@prefix)
        manifest.write("", "X-Object-Manifest" => "#{@container.name}/#{@prefix}")
      end
    end
  end
end
