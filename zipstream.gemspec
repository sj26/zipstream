require File.expand_path('../lib/zipstream/version.rb', __FILE__)

Gem::Specification.new do |s|
  s.name = "zipstream"
  s.version = Zipstream::VERSION
  s.summary = "Create zip files directly to a stream."

  s.author = "Samuel Cochran"
  s.email = "sj26@sj26.com"
  s.homepage = "http://github.com/sj26/zipstream"

  s.files = Dir[
    "README.md", "LICENSE", "VERSION",
    "lib/**/*.rb",
  ]
  s.require_paths = ["lib"]
  s.extra_rdoc_files = ["README.md", "LICENSE"]

  s.add_development_dependency 'rspec', '~> 2.7.0'
end
