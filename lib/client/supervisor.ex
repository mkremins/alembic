defmodule Alembic.ClientSupervisor do
	use Supervisor.Behaviour

	@doc false
	def start_link do
		:supervisor.start_link(__MODULE__, [])
	end

	@doc """
	Initializes the client supervisor, defining the child specification for an
	individual client process and tweaking the supervisor's own supervisor
	specification for optimal performance with dynamic children.
	"""
	def init(args) do
		tree = [worker(Alembic.Client, args, modules: :dynamic)]
		supervise(tree, strategy: :simple_one_for_one)
	end

	@doc """
	Spawns and begins supervising a new client process, using the translator
	module with the specified name to translate packets and using the specified
	socket to communicate with the connected client.
	"""
	def spawn_client(socket, type) do
		translator = Module.concat(Alembic.Client, type)
		case Code.ensure_loaded(translator) do
			{:module, translator} ->
				:supervisor.start_child(__MODULE__, [socket, translator])
			{:error, reason} ->
				{:error, reason}
		end
	end
end
