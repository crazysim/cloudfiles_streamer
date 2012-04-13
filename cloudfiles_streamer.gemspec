Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  s.name        = 'cloudfiles_streamer'
  s.version     = '0.1.7'
  s.date        = '2012-04-13'
  s.summary     = "Stream files on STDIN to Rackspace's CloudFiles"
  s.description = ""

  s.authors  = ["Andrew Le"]
  s.email    = 'andrew.le@receipt.com'
  s.homepage = 'http://receipt.com'

  s.require_paths = %w[lib]
  s.executables = ["cloudfiles-streamer"]

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE]

  s.add_dependency('cloudfiles', '~> 1.5')
  s.add_development_dependency('rspec', '~> 2.8')

  # = MANIFEST =
  s.files = %w[
    LICENSE
    README.md
    Rakefile
    bin/cloudfiles-streamer
    cloudfiles_streamer.gemspec
    lib/cloudfiles_streamer.rb
    lib/cloudfiles_streamer/cloudfiles_api.rb
    lib/cloudfiles_streamer/cloudfiles_api/container.rb
    lib/cloudfiles_streamer/cloudfiles_api/manifest.rb
    lib/cloudfiles_streamer/command_line_options.rb
    lib/cloudfiles_streamer/segmented_stream.rb
    lib/cloudfiles_streamer/streamer.rb
    spec/cloudfiles_streamer/cloudfiles_api/container_spec.rb
    spec/cloudfiles_streamer/cloudfiles_api/manifest_spec.rb
    spec/cloudfiles_streamer/cloudfiles_api_spec.rb
    spec/cloudfiles_streamer/command_line_options_spec.rb
    spec/cloudfiles_streamer/segmented_stream_spec.rb
    spec/cloudfiles_streamer/streamer_spec.rb
  ]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^spec\/.*_spec\.rb/ }
end
