module CacheDebugging
  class Railtie < Rails::Railtie
    config.cache_debugging = ActiveSupport::OrderedOptions.new

    # raise exceptions if templates aren't in the dependency tree
    config.cache_debugging.strict_dependencies = false

    # [0,1] - decimal (percent) of cache hits to check
    config.cache_debugging.view_sampling = 0

    initializer "cache_debugging.setup", :before => 'cache_digests' do |app|
      ActiveSupport.on_load(:action_view) do
        include CacheDebugging::CacheBlocks
        include CacheDebugging::StrictDependencies
        include CacheDebugging::ViewSampling
      end
    end
  end
end