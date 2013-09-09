module CacheDebugging
  module ViewSampling

    private

    def fragment_for(name = {}, options = nil, &block)
      if fragment = controller.read_fragment(name, options)
        return fragment unless should_sample?(options)

        uncached = _render_block(&block)
        handle_cache_mismatch(fragment, uncached, name) unless uncached == fragment

        uncached
      else
        fragment = _render_block(&block)
        controller.write_fragment(name, fragment, options)
      end
    end

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
      sample = (options || {}).fetch(:sample) do
        Rails.application.config.cache_debugging.view_sampling
      end.to_f

      rand <= sample
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