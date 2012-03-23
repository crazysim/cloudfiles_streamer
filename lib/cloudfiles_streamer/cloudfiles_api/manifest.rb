module CloudFilesStreamer
  class CloudFilesApi
    class CloudFilesObjectMissing < RuntimeError; end

    class Manifest
      MAX_RETRIES = 3

      def initialize(container, prefix, num_uploaded)
        @container = container
        @prefix = prefix
        @num_uploaded = num_uploaded
      end

      def create
        if @num_uploaded > 1
          create_for_many
        else
          create_for_one
        end
      end

      def create_for_many
        manifest = @container.create_object(@prefix)
        manifest.write("", "X-Object-Manifest" => "#{@container.name}/#{@prefix}")
      end

      def create_for_one
        objects = []
        0.upto(MAX_RETRIES) do |try_num|
          Kernel.sleep(try_num ** 2)
          objects = @container.objects(:prefix => @prefix)
          break if !objects.empty?
        end

        raise CloudFilesObjectMissing,
          "Could not find any objects with prefix '#{@prefix}'" if objects.empty?

        sole_object = @container.object(objects.first)
        sole_object.move(:name => @prefix)
      end

    end
  end
end
