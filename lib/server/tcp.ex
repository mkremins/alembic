defmodule Alembic.TCPServer do
	@moduledoc """
	TCP server listening for new connections on a particular hostname and port.
	When a new client connects, the socket object representing the connection
	is passed to the `Alembic.ClientSupervisor` module and a new client process
	is spawned to handle packets sent over the link.
	"""

	use ExActor

	alias Alembic.ClientSupervisor, as: ClientSup
	alias Alembic.Config
	alias Alembic.TCPServer, as: Server
	alias Socket.TCP

	@doc """
	Starts the TCP server, spawning an acceptor process listening for incoming
	connections on each port associated with a client type in the config.
	"""
	definit _ do
		server = self
		host = Config.get[:hostname]
		Enum.each Config.get[:client_types], fn(client) ->
			lsocket = TCP.listen(local: [address: host, port: client[:port]])
			spawn fn ->
				acceptor(server, client[:name], lsocket)
			end
		end
	end

	@doc """
	Handles a new connection by spawning a new client process and directing all
	future incoming traffic on the specified socket to that process.
	"""
	defcast connect(name, socket) do
		ClientSup.spawn_client(name, socket)
		:ok
	end

	@doc """
	Listens for a new incoming connection. When a client successfully connects,
	creates a new socket object for communication with that client and notifies
	the main server process of the existence of the new connection.
	"""
	defp acceptor(server, name, lsocket) do
		case TCP.accept(lsocket) do
			{:ok, socket} ->
				Server.connect(server, name, socket)
				acceptor(server, name, lsocket)
			error ->
				error
		end
	end
end
