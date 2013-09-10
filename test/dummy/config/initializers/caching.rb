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

class CacheMismatchException < Exception
  def initialize(template, cache_key)
    @template = template
    @cache_key = cache_key
  end

  def message
    %{Cache mismatch: #{@template}, #{@cache_key}}
  end
end

ActiveSupport::Notifications.subscribe 'cache_debugging.cache_dependency_missing' do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  raise TemplateDependencyException.new(event.payload[:partial], event.payload[:template], event.payload[:dependencies])
end

ActiveSupport::Notifications.subscribe 'cache_debugging.cache_mismatch' do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  raise CacheMismatchException.new(event.payload[:template], event.payload[:cache_key])
end