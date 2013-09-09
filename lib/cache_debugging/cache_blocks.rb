module CacheDebugging
  module CacheBlocks
    extend ActiveSupport::Concern

    included do
      alias_method_chain :cache, :blocks
    end

    def cache_with_blocks(name = {}, options = nil, &block)
      if current_template
        dependencies = CacheDigests::TemplateDigestor.new(current_template, lookup_context.rendered_format || :html, ApplicationController.new.lookup_context).nested_dependencies.deep_flatten
        cache_blocks.push({
          template: current_template,
          dependencies: dependencies
        })
        ret = cache_without_blocks(name, options, &block)
        cache_blocks.pop
        ret
      else
        cache_without_blocks(name, options, &block)
      end
    end

    private

    def cache_blocks
      @cache_blocks ||= []
    end

    def current_template
      @virtual_path
    end

    def cache_block_depth
      cache_blocks.length
    end
  end
end