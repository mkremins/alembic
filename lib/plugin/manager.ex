defmodule Alembic.PluginManager do
	@moduledoc """
	Manages the list of currently enabled plugins, issuing callbacks to each
	plugin's main callback module in response to client-issued requests.
	"""

	use ExActor

	alias Alembic.Plugin.Behaviour, as: Plugin

	@doc """
	Initializes the plugin manager with the specified list of plugins. This
	plugin list should be obtained from the server's plugin loader.
	"""
	definit plugins do
		plugins
	end

	@doc """
	Serves the specified request, taking the following steps to identify
	currently enabled plugins capable of handling the request and delegate the
	handling of the request to these plugins:

	1. Associates each plugin with a _priority value_ for the request by
	   invoking the `Alembic.Plugin.Behaviour.screen/2` plugin callback on each
	   plugin, passing the request and client as arguments and making note of
	   the priority value each plugin returns.

	2. Sorts the list of currently enabled plugins by priority and discards
	   those plugins that declared a priority of `:ignore` (indicating an
	   intention to ignore the request), producing an appropriately ordered
	   list of plugins that should each be given an opportunity to handle the
	   request.

	3. Takes plugins from the list – in order of priority – and invokes the
	   `Alembic.Plugin.Behaviour.handle/2` plugin callback on each plugin,
	   passing the request and client as arguments. Stops either when every
	   plugin in the list has been given a chance to handle the request, or
	   when one of the plugins consumes the request by returning `:consume`
	   from the `handle` callback.

	Any currently enabled plugin that errors out during this process (by
	returning `{:error, reason}` from either callback, or by throwing an
	exception of any sort) should be disabled.
	"""
	defcast serve(request, client), state: plugins do
		lc plugin inlist plugins do
			{plugin.screen(request, client), plugin}
		end |> Enum.sort fn({first, _}, {second, _}) ->
			# true if `first` is lower priority than `second`, otherwise false
			cond do
				first == :ignore -> true
				second == :ignore -> false
				true -> first < second
			end
		end |> Enum.filter_map &(elem(&1, 0) != :ignore), &elem(&1, 1)
			|> Enum.take_while &(&1.handle(request, client) != :consume)
		:ok
	end
end
