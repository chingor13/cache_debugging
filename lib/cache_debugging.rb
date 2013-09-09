require 'rails'
if Rails::VERSION::MAJOR != 4
  begin
    require 'cache_digests'
  rescue LoadError
    raise "You must use the 'cache_digests' gem if your a running Rails 3"
  end
end

module CacheDebugging
  autoload :CacheBlocks, 'cache_debugging/cache_blocks'
  autoload :StrictDependencies, 'cache_debugging/strict_dependencies'
  autoload :ViewSampling, 'cache_debugging/view_sampling'
end

require 'cache_debugging/railtie'