# -*- encoding: utf-8 -*-
require File.expand_path('../lib/lims_info/version', __FILE__)

Gem::Specification.new do |s|
  s.add_dependency "thor", "~> 0.14.6"
  s.add_development_dependency "bundler", "~> 1.0"
  s.add_development_dependency "rdoc", "~> 3.9"
  s.add_development_dependency "rspec", "~> 2.3"
  s.authors = ['Jim Vallandingham']
  s.description = %q{}
  s.email = 'none@none.com'
  s.executables = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  s.extra_rdoc_files = ['LICENSE', 'README.textile']
  s.files = `git ls-files`.split("\n")
  s.homepage = 'http://github.com/vlandham/hastie'
  s.name = 'hastie'
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')
  s.summary = s.description
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.version = LimsInfo::VERSION.dup
end
