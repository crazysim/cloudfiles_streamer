Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  s.name        = 'cloudfiles_streamer'
  s.version     = '0.1.0'
  s.date        = '2012-03-02'
  s.summary     = "Stream files on STDIN to Rackspace's CloudFiles"
  s.description = ""

  s.authors  = ["Andrew Le"]
  s.email    = 'andrew.le@receipt.com'
  s.homepage = 'http://receipt.com'

  s.require_paths = %w[lib]
  s.executables = ["cloudfiles-stream"]

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README LICENSE]

  s.add_dependency('cloudfiles', '~> 1.5')
  s.add_development_dependency('rspec', '~> 2.8')

  # = MANIFEST =
  s.files = %w[

  ]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^spec\/.*_spec\.rb/ }
end
