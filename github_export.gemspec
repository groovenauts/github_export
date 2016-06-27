# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'github_export/version'

Gem::Specification.new do |spec|
  spec.name          = "github_export"
  spec.version       = GithubExport::VERSION
  spec.authors       = ["akm"]
  spec.email         = ["akm2000@gmail.com"]

  spec.summary       = %q{Export Issues, Contents and so on }
  spec.description   = %q{Export Issues, Contents and so on}
  spec.homepage      = "https://github.com/groovenauts/github_export"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "octokit"
  spec.add_runtime_dependency "faraday", "= 0.9.1"
  spec.add_runtime_dependency "thor"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
