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
	def start_link() do
		{:ok, _pid} = :supervisor.start_link(__MODULE__, [])
	end

	@doc false
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
