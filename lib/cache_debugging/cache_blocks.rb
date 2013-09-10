module CacheDebugging
  module CacheBlocks
    extend ActiveSupport::Concern

    included do
      alias_method_chain :cache, :blocks
    end

    # every time we start a cache block, we want to store the template and the block's dependencies
    def cache_with_blocks(name = {}, options = nil, &block)
      if current_template
        dependencies = Digestor.new(
          current_template,
          lookup_context.rendered_format || :html, ApplicationController.new.lookup_context
        ).nested_dependencies

        cache_blocks.push({
          template: current_template,
          dependencies: Utils.deep_flatten(dependencies)
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

    def cache_depth
      cache_blocks.length
    end

  end
end