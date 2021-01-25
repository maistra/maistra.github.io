# -*- encoding: utf-8 -*-
# stub: jekyll-asciidoc 3.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "jekyll-asciidoc".freeze
  s.version = "3.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/asciidoctor/jekyll-asciidoc/issues", "changelog_uri" => "https://github.com/asciidoctor/jekyll-asciidoc/blob/master/CHANGELOG.adoc", "mailing_list_uri" => "http://discuss.asciidoctor.org", "source_code_uri" => "https://github.com/asciidoctor/jekyll-asciidoc" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Dan Allen".freeze, "Paul Rayner".freeze]
  s.date = "2019-08-31"
  s.description = "A Jekyll plugin that converts the AsciiDoc source files in your site to HTML pages using Asciidoctor.".freeze
  s.email = ["dan.j.allen@gmail.com".freeze]
  s.homepage = "https://github.com/asciidoctor/jekyll-asciidoc".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.3".freeze
  s.summary = "A Jekyll plugin that converts the AsciiDoc source files in your site to HTML pages using Asciidoctor.".freeze

  s.installed_by_version = "3.0.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<asciidoctor>.freeze, [">= 1.5.0"])
      s.add_runtime_dependency(%q<jekyll>.freeze, [">= 3.0.0"])
      s.add_development_dependency(%q<deep-cover-core>.freeze, ["~> 0.7.0"])
      s.add_development_dependency(%q<pygments.rb>.freeze, ["~> 1.2.1"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 12.3.2"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.8.0"])
      s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.74.0"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.17.0"])
    else
      s.add_dependency(%q<asciidoctor>.freeze, [">= 1.5.0"])
      s.add_dependency(%q<jekyll>.freeze, [">= 3.0.0"])
      s.add_dependency(%q<deep-cover-core>.freeze, ["~> 0.7.0"])
      s.add_dependency(%q<pygments.rb>.freeze, ["~> 1.2.1"])
      s.add_dependency(%q<rake>.freeze, ["~> 12.3.2"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.8.0"])
      s.add_dependency(%q<rubocop>.freeze, ["~> 0.74.0"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.17.0"])
    end
  else
    s.add_dependency(%q<asciidoctor>.freeze, [">= 1.5.0"])
    s.add_dependency(%q<jekyll>.freeze, [">= 3.0.0"])
    s.add_dependency(%q<deep-cover-core>.freeze, ["~> 0.7.0"])
    s.add_dependency(%q<pygments.rb>.freeze, ["~> 1.2.1"])
    s.add_dependency(%q<rake>.freeze, ["~> 12.3.2"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.8.0"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0.74.0"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.17.0"])
  end
end
