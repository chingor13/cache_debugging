require 'test_helper'

class CacheDebuggingTest < ActionDispatch::IntegrationTest
  self.use_transactional_fixtures = true
  fixtures :all

  def setup
    Rails.cache.clear
    super
  end

  def teardown
    super
  end

  test 'basic caching' do
    with_view_sampling(false) do
      with_template_dependencies(false) do
        get workers_path
        assert_response :success
        assert_template partial: "workers/_tweets", count: Worker.count

        # second visit, everything should be cached
        get workers_path
        assert_template partial: "workers/_tweets", count: Worker.count

        # modify a worker
        assert Worker.first.touch
        get workers_path
        assert_template partial: "workers/_tweets", count: Worker.count + 1
      end
    end
  end

  test 'template dependencies' do
    with_view_sampling(false) do
      with_template_dependencies(true) do
        get workers_path
        assert_response :error
        assert response.body.match("not in template cache dependency tree")
      end
    end
  end

  test 'view_sampling' do
    # set sample rate to 1
    with_view_sampling(1) do
      with_template_dependencies(false) do
        get workers_path
        assert_response :success

        # fake a dependency change that does not touch the cache key
        Tweet.create!({
          worker: Worker.first,
          message: "Test message"
        })

        # second request, should double check the cache
        get workers_path
        assert_response :error
        assert response.body.match("Cache mismatch")
      end
    end
  end

  private

  def with_view_sampling(val)
    old_val = Rails.application.config.cache_debugging.view_sampling
    Rails.application.config.cache_debugging.view_sampling = val
    yield
    Rails.application.config.cache_debugging.view_sampling = old_val
  end

  def with_template_dependencies(val)
    old_val = Rails.application.config.cache_debugging.strict_dependencies
    Rails.application.config.cache_debugging.strict_dependencies = val
    yield
    Rails.application.config.cache_debugging.strict_dependencies = old_val
  end
end