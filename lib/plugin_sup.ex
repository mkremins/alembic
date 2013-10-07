defmodule Alembic.PluginManager do
  @moduledoc """
  Manages the list of currently enabled plugins, issuing callbacks to each
  plugin's main callback module in response to client-issued requests and
  mediating interactions between plugins with potentially conflicting spheres
  of responsibility.
  """

  use ExActor

  alias Alembic.Config

  @doc """
  Initializes the plugin manager, taking the following steps to locate and
  load plugins:

  1. Invokes `load_plugins/1` on each plugin directory name specified in the
     server config, producing a list whose every element is itself a list of
     plugins that the manager attempted to load from one of these plugin
     directories.

  2. Concatenates the list of lists into a single list of plugins. Each
     element of this single list is either a tuple `{:ok, plugin}`, where
     `plugin` is itself a tuple mapping a loaded plugin's name to that
     plugin's main callback module, or `{:error, reason}` in the event that a
     particular plugin could not be loaded.

  3. Filters the list of plugins, removing each error tuple such that only
     successfully loaded plugins remain. During this step, each error message
     produced by attempting and failing to load a particular plugin may also
     be logged.

  4. Produces a new list containing only the second element (a name–module
     mapping) of each tuple `{:ok, plugin}` remaining in the filtered list.
     This new list, which contains every plugin that was successfully loaded
     from the plugin directories specified in the server config, is then used
     as the plugin manager's internal state.

  Each currently enabled plugin is represented in the plugin manager's state
  by a tuple `{name, module}`, where `name` is the plugin's unique name
  (specified in the plugin's manifest) and `module` is the plugin's main
  callback module (responsible for implementing `Alembic.Plugin.Behaviour`
  callback functions on that plugin's behalf).
  """
  definit _ do
    Enum.map(Config.get[:plugins], &load_plugins/1)
    |> Enum.concat
    |> Enum.reject(fn(plugin) ->
      # true if `plugin` should be excluded from final list, else false
      case plugin do
        {:ok, plugin} ->
          true
        {:error, reason} ->
          # TODO: log the error
          false
      end
    end)
    |> Enum.map(&elem(&1, 1))
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
    end
    |> Enum.sort(fn({first, _}, {second, _}) ->
      # true if `first` is lower priority than `second`, otherwise false
      cond do
        first == :ignore -> true
        second == :ignore -> false
        true -> first < second
      end
    end)
    |> Enum.filter_map(&(elem(&1, 0) != :ignore), &elem(&1, 1))
    |> Enum.take_while(&(&1.handle(request, client) != :consume))
    :ok
  end

  @doc """
  Attempts to the file at the specified path as a plugin. Returns
  `{:ok, plugin}` on success, `{:error, reason}` on failure. In the case of
  success, `plugin` is a tuple whose first element is the plugin's name
  (taken from the plugin's manifest) and whose second element is the callback
  module responsible for implementing the `Alembic.Plugin.Behaviour` callback
  functions on behalf of the loaded plugin.
  """
  defp load_plugin(filename) do
    filename = Path.expand(filename)
    if File.exists?(filename) do
      # TODO: `Code.require_file/1` is probably unsafe here
      case get_callback_module(Code.require_file(filename)) do
        nil ->
          {:error, "couldn't find plugin callback module"}
        module ->
          {:ok, {module.alembic_plugin[:name], module}}
      end
    else
      {:error, :enoent}
    end
  end

  @doc """
  Attempts to load every file in the directory at the specified path as a
  plugin by calling `load_plugin/1` on every file in the directory in turn.
  Returns a list of plugins on success, `{:error, reason}` on failure.

  Note that this method is still considered to have succeeded if one or more
  plugins in the directory failed to load. In fact, it is considered to have
  failed if and only if the call to `File.ls/1` resulted in failure.
  """
  defp load_plugins(dirname) do
    case File.ls(Path.expand(dirname)) do
      {:ok, files} ->
        Enum.map files, &load_plugin/1
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Given a list of modules associated with a particular plugin, returns that
  plugin's callback module – the module that is responsible for implementing
  the `Alembic.Plugin.Behaviour` callback functions on that plugin's behalf.

  If no callback module is found, `nil` is returned instead.
  """
  defp get_callback_module(modules) do
    Enum.find modules, fn(module) ->
      behaviours = module.module_info(:attributes)[:behaviour]
      Enum.member? behaviours, Alembic.Plugin.Behaviour
    end
  end
end
