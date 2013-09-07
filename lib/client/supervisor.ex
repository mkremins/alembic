defmodule Alembic.ClientSupervisor do
	use Supervisor.Behaviour

	@doc false
	def start_link do
		:supervisor.start_link(__MODULE__, [])
	end

	def init(args) do
		tree = [worker(Alembic.Client, args, modules: :dynamic)]
		supervise(tree, strategy: :simple_one_for_one)
	end

	def spawn_client(socket) do
		# TODO
	end
end
