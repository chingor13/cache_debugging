module CacheDebugging
  class Railtie < Rails::Railtie
    config.cache_debugging = ActiveSupport::OrderedOptions.new(
      # raise exceptions if templates aren't in the dependency tree
      strict_dependencies: false,

      # [0,1] - decimal (percent) of cache hits to check
      view_sampling: 0
    )

    initializer "cache_debugging.setup", :before => 'cache_digests' do |app|
      if app.config.cache_debugging.strict_dependencies
        ActiveSupport.on_load(:action_view) do
          include CacheDebugging::StrictDependencies
        end
      end

      if app.config.cache_debugging.view_sampling
        ActiveSupport.on_load(:action_view) do
          include CacheDebugging::ViewSampling
        end
      end
    end
  end
end