# Use this module to keep helper methods out of ActionView::Base scope
module CacheDebugging
  module Utils
    # recursively flatten complex array/hash objects
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

    # wrapper for ActiveSupport::Notification publish
    def self.publish_notification(name, extra = {})
      ActiveSupport::Notifications.publish(
        name, 
        Time.now,             # not a block, so fake the start time
        Time.now,             # not a block, so fake the finish time
        SecureRandom.hex(10), # generate a unique id
        extra
      )
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