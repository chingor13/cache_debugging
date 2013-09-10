[![Build Status](https://travis-ci.org/chingor13/cache_debugging.png)](https://travis-ci.org/chingor13/cache_debugging)

# CacheDebugging

`cache_debugging` aims to detangle `cache_digests`'s template dependencies.  It currently contains 2 different hooks to check for cache integrity.

## StrictDependencies

This module ensures that every `render` call within a cache block is called on a partial that is in the callers template dependencies.

### Why?

We may not have declared all of our explicit template dependencies.

Consider:

```
cache @workers do
  render @workers
end
```

Seems reasonable, as it will assume `workers/worker` is the partial to be depended upon. 

We could also declaring the template explicitly:

```
cache @workers do
  render partial: 'workers/worker', collection: @workers
end
```

What if, however, `@workers` is a collection of duck-typed objects that behave like workers?  We have to explicitly declare the dependencies:

```
<%# Template Dependency: plumbers/plumber %>
<%# Template Dependency: gardeners/gardener %>
…
<%# Template Dependency: electricians/electrician %>
cache @workers do
  render @workers
end
```

How do we ensure that all the possible worker types are declared?

### Usage

In application.rb (or environment config):

```
config.cache_debugging.strict_dependencies = true
```

We keep track of each cache block with it's dependencies and trigger an ActiveSupport notification (`cache_debugging.cache_dependency_missing`) if we're rendering a partial not included any parent's template dependencies.  You can handle this notification any way you want.

## View Sampling

This module ensures that you have declared all the variable dependencies for your cache block.

### Why?

We might be missing a cache variable and not know it.

Consider an view of a bug report ticket that can be assigned:

```
# tickets/index.html.erb
<% cache @tickets do %>
  <%= render @tickets %>
<% end %>

# tickets/_ticket.html.erb
<% cache ticket do %>
  <tr>
    <td><%= ticket.id %></td>
    <td><%= ticket.title %></td>
    <td><%= ticket.assigned_to.name %></td>
  </tr>
<% end %>
```

Let's say we decided to replace `assigned_to.name` with "me" if the ticket is assigned to me.  So we update the ticket partial:

```
# tickets/_ticket.html.erb
<% cache(ticket, current_user) do %>
  <tr>
    <td><%= ticket.id %></td>
    <td><%= ticket.title %></td>
    <td><%= ticket.assigned_to == current_user ? "me" : ticket.assigned_to.name %></td>
  </tr>
<% end %>
```

We've updated the cache block for the singular ticket, but forgotten to update the collection cache block.  We won't be notified that we're rendering a different view than we expect.

### Usage

In application.rb (or environment config):

```
config.cache_debugging.view_sampling = 0.1
```

Every X% of cache hits (10% for the above example), we will re-render the cache block anyways and compare the results.  If they don't match, we trigger and ActiveSupport notification (`cache_debugging.cache_mismatch`). You can handle this notification any way you want.