# frozen_string_literal: true

require_relative "lib/yard-rustdoc/version"

Gem::Specification.new do |spec|
  spec.name = "yard-rustdoc"
  spec.version = YARD::Rustdoc::VERSION
  spec.licenses = ["MIT"]
  spec.authors = ["Jimmy Bourassa"]
  spec.email = ["jbourassa@gmail.com"]

  spec.summary = "Generate YARD documentation for Magnus-based Rust gems."
  spec.homepage = "https://github.com/oxidize-rb/yard-rustdoc"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir["{lib}/**/*", "LICENSE", "README.md"]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "yard", "~> 0.9"
  spec.add_dependency "syntax_tree", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "standard", "~> 1.9"
end
