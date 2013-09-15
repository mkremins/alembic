defmodule Alembic.TCPServer do
	@moduledoc """
	TCP server listening for new connections. When a client connects, a new
	client process is spawned and given control of the socket over which the
	connection was established.

	In order to accomodate multiple different client protocols, each protocol
	is associated in the server config file with a particular port. This module
	spawns a separate acceptor process for each of these ports; as a result,
	each client connecting to the server can be assigned a translator module
	appropriate to its particular protocol before any packets are exchanged.
	"""

	use ExActor

	alias Alembic.Config
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
		Alembic.ClientSupervisor.spawn_client(name, socket)
	end

	@doc """
	Listens for a new incoming connection. When a client successfully connects,
	creates a new socket object for communication with that client and notifies
	the main server process of the existence of the new connection.
	"""
	defp acceptor(server, name, lsocket) do
		case TCP.accept(lsocket) do
			{:ok, socket} ->
				connect(server, name, socket)
				acceptor(server, name, lsocket)
			error ->
				error
		end
	end
end
