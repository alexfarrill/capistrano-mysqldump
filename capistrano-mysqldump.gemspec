# coding: utf-8
Gem::Specification.new do |s|
  s.name = "capistrano-mysqldump"
  s.version = "1.1.2"

  s.authors = ["Alex Farrill"]
  s.date = "2013-07-03"
  s.description = ""
  s.email = "alex.farrill@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]

  s.files         = Dir["lib/**/*"]

  # explicitly disable test files until they're used
  # s.test_files    = Dir['test/**/*']

  s.files = `git ls-files`.split($/)
  s.homepage = "http://github.com/alexfarrill/capistrano-mysqldump"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "Capistrano extension to run mysqldump remotely, download, and import into your local Rails development database"

  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.add_runtime_dependency(%q<capistrano>, [">= 1.0.0"])
  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
  s.add_development_dependency "shoulda"
  s.add_development_dependency "test-unit"
end
