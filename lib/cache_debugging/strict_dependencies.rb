module CacheDebugging
  module StrictDependencies
    extend ActiveSupport::Concern

    included do
      alias_method_chain :render, :template_dependencies
    end

    # every time we render, we want to check if the partial is in the dependency list
    def render_with_template_dependencies(*args, &block)
      if Utils.strict_dependencies_enabled? && cache_blocks.length > 0
        options = args.first
        if options.is_a?(Hash)
          if partial = options[:partial]
            validate_partial!(partial)
          end
        else
          (options.respond_to?(:to_ary) ? options.to_ary : Array(options)).each do |object|
            validate_partial!(Utils.object_partial_path(object))
          end
        end
      end
      render_without_template_dependencies(*args, &block)
    end

    private

    def validate_partial!(partial)
      unless valid_partial?(partial)
        Utils.publish_notification("cache_debugging.cache_dependency_missing", {
          partial: partial,
          template: cache_blocks.last[:template],
          dependencies: cache_blocks.last[:dependencies]
        })
      end
    end

    def valid_partial?(partial)
      cache_blocks.last[:dependencies].include?(partial)
    end

  end
end
