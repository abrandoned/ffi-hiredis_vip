# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ffi/hiredis_vip/version'

Gem::Specification.new do |spec|
  spec.name          = "ffi-hiredis_vip"
  spec.version       = FFI::HiredisVip::VERSION
  spec.authors       = ["Brandon Dewitt"]
  spec.email         = ["brandonsdewitt@gmail.com"]

  spec.summary       = %q{ FFI Wrapper around hiredis-vip for Hiredis and cluster support }
  spec.description   = %q{ FFI Wrapper for hiredis-vip }
  #spec.homepage      = "url"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "ffi"
  spec.add_runtime_dependency "ffi-hiredis_vip-core", ">= 0.1.0.pre4"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "pry"
end
