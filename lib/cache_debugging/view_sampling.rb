module CacheDebugging
  module ViewSampling
    extend ActiveSupport::Concern

    included do
      alias_method_chain :cache, :view_sampling
    end

    def cache_with_view_sampling(name = {}, options = nil, &block)
      cache_without_view_sampling(name, options, &block)
      @_force_view_sampling = false if cache_depth == @_force_view_sampling
    end

    private

    # since there are no hooks on a cache hit, that also has access to the render block, we
    #   must override fragement_for here
    def fragment_for(name = {}, options = nil, &block)
      if fragment = controller.read_fragment(name, options)
        return fragment unless should_sample?(options)
        @_force_view_sampling = cache_depth

        uncached = _render_block(&block)
        handle_cache_mismatch(fragment, uncached, name) unless uncached == fragment

        uncached
      else
        fragment = _render_block(&block)
        controller.write_fragment(name, fragment, options)
      end
    end

    # code taken from fragment_for
    def _render_block(&block)
      # VIEW TODO: Make #capture usable outside of ERB
      # This dance is needed because Builder can't use capture
      pos = output_buffer.length
      yield
      output_safe = output_buffer.html_safe?
      fragment = output_buffer.slice!(pos..-1)
      if output_safe
        self.output_buffer = output_buffer.class.new(output_buffer)
      end
      fragment
    end

    def current_template
      @virtual_path
    end

    def should_sample?(options)
      return false unless view_sampling_rate
      return true if @_force_view_sampling

      sample = (options || {}).fetch(:sample) { view_sampling_rate }.to_f
      rand <= sample
    end

    def view_sampling_rate
      Rails.application.config.cache_debugging.view_sampling
    end

    def handle_cache_mismatch(cached, uncached, cache_key)
      ActiveSupport::Notifications.publish("cache_debugging.cache_mismatch", Time.now, Time.now, SecureRandom.hex(10), {
        cached: cached,
        uncached: uncached,
        template: current_template,
        cache_key: cache_key
      })
    end
  end
end