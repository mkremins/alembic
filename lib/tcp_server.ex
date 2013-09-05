defmodule Alembic.TCPServer do
	@moduledoc """
	TCP server listening for new connections on a particular hostname and port.
	When a new client connects, the socket object representing the connection
	is passed to the `Alembic.ClientSupervisor` module and a new client process
	is spawned to handle packets sent over the link.
	"""

	use GenServer.Behaviour

	@doc false
	def start_link do
		:gen_server.start_link(__MODULE__, [], [])
	end

	@doc """
	Starts the TCP server and spawns an acceptor process listening for incoming
	connections on the hostname and port specified by the server config.
	"""
	def init(_args) do
		config = Alembic.Config.get
		listening = Socket.TCP.listen(local: [address: config[:host], port: config[:port]])
		server_pid = self
		spawn fn ->
			acceptor(listening, server_pid)
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
		case Socket.TCP.accept(listening) do
			{:ok, socket} ->
				:gen_server.cast(pid, {:connect, socket})
				acceptor(listening, pid)
			error ->
				error
		end
	end
end
