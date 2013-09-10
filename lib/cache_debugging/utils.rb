module CacheDebugging
  module Utils
    def self.deep_flatten(array_or_hash)
      case array_or_hash
      when Array
        array_or_hash.map do |value|
          if value.is_a?(Hash) || value.is_a?(Array)
            deep_flatten(value)
          else
            value
          end
        end.flatten
      when Hash
        deep_flatten(array_or_hash.keys + array_or_hash.values)
      end
    end

    def self.publish_notification(name, extra = {})
      ActiveSupport::Notifications.publish(
        name, 
        Time.now,             # not a block, so fake the start time
        Time.now,             # not a block, so fake the finish time
        SecureRandom.hex(10), # generate a unique id
        extra
      )
    end

    def self.strict_dependencies_enabled?
      !!Rails.application.config.cache_debugging.strict_dependencies
    end

    def self.view_sampling_enabled?
      !!view_sampling_rate
    end

    def self.view_sampling_rate
      Rails.application.config.cache_debugging.view_sampling
    end

    def self.object_partial_path(object)
      partial = begin
        object.to_partial_path
      rescue 
        object.class.model_name.partial_path
      end
      partial.split("/").tap{|parts| parts.last.gsub!(/^_?/, "_")}.join("/")
    end
  end
end