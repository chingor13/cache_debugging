module CacheDebugging
  module StrictViewCacheDependencies
    extend ActiveSupport::Concern

    class TemplateDependencyException < Exception
      def initialize(partial, template, dependencies)
        @partial = partial
        @template = template
        @dependencies = dependencies
      end

      def message
        %{#{@partial} not in template cache dependency tree for #{@template}: #{@dependencies.inspect}"}
      end
    end

    included do
      alias_method_chain :cache, :template_dependencies
      alias_method_chain :render, :template_dependencies
    end

    def cache_with_template_dependencies(name = {}, options = nil, &block)
      if current_template
        dependencies = CacheDigests::TemplateDigestor.new(current_template, lookup_context.rendered_format || :html, ApplicationController.new.lookup_context).nested_dependencies.deep_flatten
        cache_blocks.push({
          :template => current_template,
          :dependencies => dependencies
        })
        ret = cache_without_template_dependencies(name, options, &block)
        cache_blocks.pop
        ret
      else
        cache_without_template_dependencies(name, options, &block)
      end
    end

    def cache_blocks
      @cache_blocks ||= []
    end

    def current_template
      @virtual_path
    end

    def render_with_template_dependencies(*args)
      if cache_blocks.length > 0
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
      render_without_template_dependencies(*args)
    end

    protected

    def validate_partial!(partial)
      unless valid_partial?(partial)
        raise TemplateDependencyException.new(partial, cache_blocks.last[:template], cache_blocks.last[:dependencies])
      end
    end

    def valid_partial?(partial)
      cache_blocks.last[:dependencies].include?(partial)
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
