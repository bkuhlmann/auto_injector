# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "auto_injector"
  spec.version = "0.5.0"
  spec.authors = ["Brooke Kuhlmann"]
  spec.email = ["brooke@alchemists.io"]
  spec.homepage = "https://www.alchemists.io/projects/auto_injector"
  spec.summary = "Automates the injection of dependencies for your class."
  spec.license = "Hippocratic-2.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/bkuhlmann/auto_injector/issues",
    "changelog_uri" => "https://www.alchemists.io/projects/auto_injector/versions",
    "documentation_uri" => "https://www.alchemists.io/projects/auto_injector",
    "funding_uri" => "https://github.com/sponsors/bkuhlmann",
    "label" => "Auto Injector",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/bkuhlmann/auto_injector"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = "~> 3.1"
  spec.add_dependency "marameters", "~> 0.4"
  spec.add_dependency "zeitwerk", "~> 2.5"

  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.files = Dir["*.gemspec", "lib/**/*"]
end
