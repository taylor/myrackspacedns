# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "myrackspacedns/version"

Gem::Specification.new do |s|
  s.name        = "myrackspacedns"
  s.version     = MyRackspaceDNS::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Taylor Carpenter"]
  s.email       = ["taylor@codecafe.com"]
  s.homepage    = ""
  s.summary     = %q{MyRackspaceDNS}
  s.description = %q{MyRackspaceDNS}

  s.rubyforge_project = "myrackspacedns"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "httpclient"

  #s.add_development_dependency "rspec"
  #s.add_development_dependency "cucumber"
  #s.add_development_dependency "aruba"
  #s.add_development_dependency "webmock"
end
