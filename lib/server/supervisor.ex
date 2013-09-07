defmodule Alembic.Supervisor do
	@moduledoc """
	Supervises the core server processes, acting as the root of the supervision
	tree for the entire application.
	"""

	use Supervisor.Behaviour

	@doc false
	def start_link(args) do
		:supervisor.start_link(__MODULE__, args)
	end

	@doc """
	Starts each of the primary server processes in turn.
	"""
	def init(args) do
		tree = [
			worker(Alembic.Config, args),
			worker(Alembic.ClientSupervisor, args),
			worker(Alembic.EventManager, args, modules: :dynamic),
			worker(Alembic.PluginLoader, args),
			worker(Alembic.TCPServer, args)
		]
		supervise(tree, strategy: :one_for_one)
	end
end
