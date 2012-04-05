require 'cloudfiles'

module CloudFilesStreamer
  class CloudFilesApi

	def self.establish_connection(username, api_key)
      SwiftClient.read_timeout = 120
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
  end
end
