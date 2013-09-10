# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
require File.expand_path('../lib/cache_debugging/version', __FILE__)
Gem::Specification.new do |s|
  s.name = "cache_debugging"
  s.version = CacheDebugging::VERSION
  s.description = 'Verify cache key dependencies'
  s.summary = 'Verify cache key dependencies via random sampling'
  s.add_dependency "rails", ">= 3.2.0"

  s.author = "Jeff Ching"
  s.email = "ching.jeff@gmail.com"
  s.homepage = "http://github.com/chingor13/cache_debugging"
  s.license = "MIT"

  s.files = `git ls-files`.split("\n")
  s.test_files = Dir.glob('test/*_test.rb')

  s.add_development_dependency "sqlite3"
end
