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
  end
end