module CacheDebugging
  module StrictDependencies
    extend ActiveSupport::Concern

    included do
      alias_method_chain :render, :template_dependencies
    end

    def render_with_template_dependencies(*args, &block)
      if should_check_template_dependencies? && cache_blocks.length > 0
        options = args.first
        if options.is_a?(Hash)
          if partial = options[:partial]
            validate_partial!(partial)
          end
        else
          (options.respond_to?(:to_ary) ? options.to_ary : Array(options)).each do |object|
            validate_partial!(object_partial_path(object))
          end
        end
      end
      render_without_template_dependencies(*args, &block)
    end

    private

    def validate_partial!(partial)
      unless valid_partial?(partial)
        ActiveSupport::Notifications.publish("cache_debugging.cache_dependency_missing", Time.now, Time.now, SecureRandom.hex(10), {
          partial: partial,
          template: cache_blocks.last[:template],
          dependencies: cache_blocks.last[:dependencies]
        })
      end
    end

    def valid_partial?(partial)
      cache_blocks.last[:dependencies].include?(partial)
    end

    def should_check_template_dependencies?
      Rails.application.config.cache_debugging.strict_dependencies
    end

    def object_partial_path(object)
      partial = begin
        object.to_partial_path
      rescue 
        object.class.model_name.partial_path
      end
      partial.split("/").tap{|parts| parts.last.gsub!(/^_?/, "_")}.join("/")
    end
  end
end
