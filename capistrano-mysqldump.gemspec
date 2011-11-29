# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{capistrano-mysqldump}
  s.version = "1.07"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Alexander Farrill}]
  s.date = %q{2011-11-29}
  s.description = %q{Capistrano extension to run mysqldump remotely, download, and import into your local Rails development database}
  s.email = %q{alex.farrill@gmail.com}
  s.extra_rdoc_files = [%q{README}, %q{lib/capistrano/mysqldump.rb}]
  s.files = [%q{MIT-LICENSE}, %q{Manifest}, %q{README}, %q{Rakefile}, %q{lib/capistrano/mysqldump.rb}, %q{capistrano-mysqldump.gemspec}]
  s.homepage = %q{http://capistrano-mysqldump.github.com/capistrano-mysqldump/}
  s.rdoc_options = [%q{--line-numbers}, %q{--inline-source}, %q{--title}, %q{Capistrano-mysqldump}, %q{--main}, %q{README}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{capistrano-mysqldump}
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{Capistrano extension to run mysqldump remotely, download, and import into your local Rails development database}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<capistrano>, [">= 1.0.0"])
    else
      s.add_dependency(%q<capistrano>, [">= 1.0.0"])
    end
  else
    s.add_dependency(%q<capistrano>, [">= 1.0.0"])
  end
end
