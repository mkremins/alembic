defmodule Alembic.Plugin.Behaviour do
	use Behaviour

	alias Alembic.Client
	alias Alembic.Request

	@doc false
	defmacro __using__(_module, _opts) do
		quote do
			@behaviour Alembic.Plugin.Behaviour

			@doc """
			Fallback clause of the expected callback function `handle/2`. Used
			to ensure that a well-defined plugin's callback module will not
			throw a missing function clause error when this callback is invoked
			by the server's plugin manager.
			"""
			def handle(_request, _client) do
				:ok
			end

			@doc """
			Fallback clause of the expected callback function `screen/2`. Used
			to ensure that a well-defined plugin's callback module will not
			throw a missing function clause error when this callback is invoked
			by the server's plugin manager.
			"""
			def screen(_request, _client) do
				:ignore
			end
		end
	end

	@doc """
	Returns the current plugin's manifest. A valid plugin manifest is a keyword
	list with the following key-value pairs:

	* `name`: the name of the plugin, as a string
	* `version`: the plugin's SemVer-compliant version number, as a string
	"""
	defcallback alembic_plugin :: [name: String.t, version: String.t]

	@doc """
	Invoked by the server's plugin manager if this plugin is best-suited, of
	all currently enabled plugins, to handle this request. Which plugin is
	best-suited to handle a particular request is determined by the value each
	plugin returns as a "handle priority" when the request in question is
	passed to that plugin's implementation of `screen/2`.

	The value returned by this function is insignificant; this function is
	always invoked asynchronously, so as to ensure that the process in which
	the server's plugin manager is running does not become blocked.
	"""
	defcallback handle(Request.t, pid) :: any

	@doc """
	Invoked by the server's plugin manager each time a new request is
	submitted. The value returned by this function is used to determine which
	of the currently enabled plugins is best-suited to handle the specified
	request; this function should return either an integer to indicate the
	strength of this plugin's desire to handle the specified request (with a
	higher integer denoting a stronger desire to handle said request), or the
	atom `:ignore` if this plugin does not care about the request.
	"""
	defcallback screen(Request.t, pid) :: integer | :ignore
end
