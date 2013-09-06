require 'rails'
if Rails::VERSION::MAJOR != 4
  begin
    require 'cache_digests'
  rescue LoadError
    raise "You must use the 'cache_digests' gem if your a running Rails 3"
  end
end

module CacheDebugging
  autoload :StrictCacheViewDependencies, 'cache_debugging/strict_cache_view_dependencies'
end

require 'cache_debugging/railtie'