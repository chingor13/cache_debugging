module CacheDebugging
  class Railtie < Rails::Railtie
    config.cache_debugging = ActiveSupport::OrderedOptions.new

    initializer "cache_debugging.setup" do |app|

      if app.config.cache_debugging.enable_strict_view_cache_dependencies
        ActiveSupport.on_load('action_view') do
          include CacheDebugging::StrictViewCacheDependencies
        end
      end

    end
  end
end