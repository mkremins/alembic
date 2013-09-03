defmodule Alembic.Supervisor do
	@moduledoc """
	Main supervisor. Supervises the following processes:
	  * `Alembic.ClientSupervisor`
	  * `Alembic.EventManager`
	  * `Alembic.PluginLoader`
	  * `Alembic.TCPServer`
	"""

	use Supervisor.Behaviour

	@doc """
	Starts the supervisor. Returns `{:ok, pid}` on success.
	"""
	def init(args) do
		tree = [
			worker(Alembic.ClientSupervisor, args),
			worker(Alembic.EventManager, args),
			worker(Alembic.PluginLoader, args),
			worker(Alembic.TCPServer, args)
		]
		supervise(tree, strategy: :one_for_one)
	end
end
