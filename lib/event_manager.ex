defmodule Alembic.EventManager do
	@manager __MODULE__

	@doc """
	Starts the event manager. Returns `{:ok, pid}` on success.
	"""
	def start_link do
		{:ok, pid} = :gen_event.start_link({:local, @manager})
	end

	@doc """
	Fires the specified event, giving each loaded plugin a chance to handle
	said event. Returns `:ok` on success.
	"""
	def notify(event_type, event_data) do
		:gen_event.notify(@manager, {event_type, event_data})
	end

	@doc """
	Loads the plugin defined by the file at the specified path and adds the
	plugin's main module to the event manager as an event handler. Returns
	`:ok` on success, `{:error, reason}` on failure.
	"""
	def load_plugin(filename) do
		filename = Path.expand(filename)
		if File.exists?(filename) do
			modules = Code.require_file(filename)
			case get_main_module(modules) do
				nil ->
					{:error, "couldn't find main module"}
				module ->
					:gen_event.add_handler(@manager, module, [])
			end
		else
			{:error, "no such file"}
		end
	end

	@doc """
	Loads every plugin in the specified directory by calling `load_plugin/1`
	on every file in the directory in turn. Returns `:ok` on success,
	`{:error, reason}` on failure.

	Note that this method is still considered to have succeeded if one or more
	plugins in the directory failed to load. In fact, it is considered to have
	failed if and only if the call to `File.ls/1` resulted in failure.
	"""
	def load_plugins(dirname) do
		dirname = Path.expand(dirname)
		case File.ls(dirname) do
			{:ok, files} ->
				Enum.each(files, &load_plugin/1)
			{:error, reason} ->
				{:error, reason}
		end
	end

	@doc """
	Given the list of modules associated with a single plugin, returns that
	plugin's main module – the module that will be directly supervised by the
	plugin supervisor.

	Uses `get_manifest/1` to make this determination: a module M will be
	considered the main module of its associated plugin if and only if it
	defines an `alembic_plugin/0` method that, when evaluated, returns a valid
	plugin manifest.
	"""
	defp get_main_module(plugin_modules) do
		main_module = nil
		Enum.each(plugin_modules, fn(module) ->
			manifest = get_manifest(module)
			if manifest and !main_module do
				main_module = module
			end
		end)
		main_module
	end

	@doc """
	Returns the result of evaluating the `alembic_plugin/0` method of the
	specified module, or `nil` if the module defines no method of that name.
	"""
	defp get_manifest(module) do
		if Module.defines?(module, {:alembic_plugin, manifest}, :def) do
			manifest
		else
			nil
		end
	end
end
