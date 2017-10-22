# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "git_queue/version"

Gem::Specification.new do |spec|
  spec.name          = "git_queue"
  spec.version       = GitQueue::VERSION
  spec.authors       = ["kinoppyd"]
  spec.email         = ["WhoIsDissolvedGirl+github@gmail.com"]

  spec.summary       = %q{Text queue database based on Git}
  spec.description   = %q{Text queue database based on Git}
  spec.homepage      = "https://github.com/kinoppyd/git-queue"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "rugged", "~> 0.26"
  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rubocop", "~> 0.51"
  spec.add_development_dependency "pry"
end
