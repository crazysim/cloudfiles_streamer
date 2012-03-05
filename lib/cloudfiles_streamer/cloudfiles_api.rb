module CloudFilesStreamer
  class CloudFilesApi
	class PrefixNotUniqueError < RuntimeError; end
	class DuplicateObjectError < RuntimeError; end

	def self.establish_connection(username, api_key)
	  @connection = CloudFiles::Connection.new(
		:username => username, :api_key => api_key)
	end

	def self.connection
	  @connection
	end

	def self.get_or_create_container(name)
	  Container.new(connection.container(name))
	rescue CloudFiles::Exception::NoSuchContainer
	  Container.new(connection.create_container(name))
	end

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
		  object = @container.objects(:prefix => prefix, :limit => 1)
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
