# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rails3-jquery-autocomplete"
  s.version = "1.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Padilla"]
  s.date = "2012-02-07"
  s.description = "Use jQuery's autocomplete plugin with Rails 3."
  s.email = "david.padilla@crowdint.com"
  s.homepage = "http://github.com/crowdint/rails3-jquery-autocomplete"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.15"
  s.summary = "Use jQuery's autocomplete plugin with Rails 3."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, ["~> 3.0"])
      s.add_development_dependency(%q<sqlite3-ruby>, [">= 0"])
      s.add_development_dependency(%q<mongoid>, [">= 2.0.0"])
      s.add_development_dependency(%q<mongo_mapper>, [">= 0.9"])
      s.add_development_dependency(%q<bson_ext>, ["~> 1.3.0"])
      s.add_development_dependency(%q<shoulda>, ["~> 2.11.1"])
      s.add_development_dependency(%q<uglifier>, [">= 0"])
      s.add_development_dependency(%q<rr>, [">= 0"])
    else
      s.add_dependency(%q<rails>, ["~> 3.0"])
      s.add_dependency(%q<sqlite3-ruby>, [">= 0"])
      s.add_dependency(%q<mongoid>, [">= 2.0.0"])
      s.add_dependency(%q<mongo_mapper>, [">= 0.9"])
      s.add_dependency(%q<bson_ext>, ["~> 1.3.0"])
      s.add_dependency(%q<shoulda>, ["~> 2.11.1"])
      s.add_dependency(%q<uglifier>, [">= 0"])
      s.add_dependency(%q<rr>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>, ["~> 3.0"])
    s.add_dependency(%q<sqlite3-ruby>, [">= 0"])
    s.add_dependency(%q<mongoid>, [">= 2.0.0"])
    s.add_dependency(%q<mongo_mapper>, [">= 0.9"])
    s.add_dependency(%q<bson_ext>, ["~> 1.3.0"])
    s.add_dependency(%q<shoulda>, ["~> 2.11.1"])
    s.add_dependency(%q<uglifier>, [">= 0"])
    s.add_dependency(%q<rr>, [">= 0"])
  end
end
