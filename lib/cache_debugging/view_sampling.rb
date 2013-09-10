module CacheDebugging
  module ViewSampling
    extend ActiveSupport::Concern

    mattr_accessor :force_sampling

    def self.force_sampling?
      !!self.force_sampling
    end

    def self.view_sampling_rate
      Rails.application.config.cache_debugging.view_sampling
    end

    def self.view_sampling_enabled?
      !!view_sampling_rate
    end

    # code taken from fragment_for
    def self.render_block(view, &block)
      # VIEW TODO: Make #capture usable outside of ERB
      # This dance is needed because Builder can't use capture
      output_buffer = view.output_buffer
      pos = output_buffer.length
      yield
      output_safe = output_buffer.html_safe?
      fragment = output_buffer.slice!(pos..-1)
      if output_safe
        view.output_buffer = output_buffer.class.new(output_buffer)
      end
      fragment
    end

    def self.should_sample?(options)
      return false unless view_sampling_enabled?
      return true if force_sampling?

      sample = (options || {}).fetch(:sample) { view_sampling_rate }.to_f
      rand <= sample
    end

    included do
      alias_method_chain :cache, :view_sampling
    end

    # clear forcing of view sampling if it's been initiated
    def cache_with_view_sampling(name = {}, options = nil, &block)
      cache_without_view_sampling(name, options, &block).tap do
        CacheDebugging::ViewSampling.force_sampling = false if cache_depth == 0
      end
    end

    private

    # since there are no hooks on a cache hit, that also has access to the render block, we
    #   must override fragement_for here
    def fragment_for(name = {}, options = nil, &block)
      if fragment = controller.read_fragment(name, options)
        return fragment unless CacheDebugging::ViewSampling.should_sample?(options)
        CacheDebugging::ViewSampling.force_sampling = true

        CacheDebugging::ViewSampling.render_block(self, &block).tap do |uncached|
          Utils.publish_notification("cache_debugging.cache_mismatch", {
            cached: fragment,
            uncached: uncached,
            template: current_template,
            cache_key: name
          }) unless uncached == fragment
        end
      else
        fragment = CacheDebugging::ViewSampling.render_block(self, &block)
        controller.write_fragment(name, fragment, options)
      end
    end

    def current_template
      @virtual_path
    end

  end
end