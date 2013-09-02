defmodule Alembic.Server do
	use GenServer.Behaviour

	@doc """
	Starts the TCP server and spawns an acceptor process listening for incoming
	connections on the specified hostname and port.
	"""
	def init({host, port}) do
		listening = Socket.TCP.listen(local: [address: host, port: port])
		spawn fn ->
			acceptor(listening, self)
		end
	end

	@doc """
	Handles a new connection by spawning a new client process and directing all
	future incoming traffic on the specified socket to that process.
	"""
	def handle_cast({:connect, socket}, state) do
		client_pid = Alembic.ClientSupervisor.spawn_client(socket)
		Socket.TCP.process(socket, client_pid)
		{:noreply, state}
	end

	@doc """
	Listens for a new incoming connection. When a client successfully connects,
	creates a new socket object for communication with that client and notifies
	the main server process of the existence of the new connection.
	"""
	defp acceptor(listening, pid) do
		case Socket.TCP.accept!(listening) do
			{:ok, socket} ->
				:gen_server.cast(pid, {:connect, socket})
				acceptor(listening, pid)
			error ->
				error
		end
	end
end
