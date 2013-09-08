defmodule Alembic.Client do
	@moduledoc """
	Represents a client currently connected to the server. Responsible for
	reading packets from, and writing packets to, the socket associated with
	that client.
	"""

	use ExActor

	defrecord State, name: "Stevesie", socket: nil

	@doc """
	Initializes a new client process, handing it control over the specified
	socket and setting up a new State record to hold information about the
	connected client.
	"""
	definit socket do
		client_pid = self
		reader = spawn fn ->
			reader(client_pid, socket)
		end
		Socket.TCP.process(socket, reader)
		initial_state(State[socket: socket])
	end

	@doc """
	Called when the reader process successfully reads a packet from the socket
	and interprets the payload as a valid request.
	"""
	defcast request(request), state: state do
		# TODO
	end

	@doc """
	Called when an attempt to read from the socket returns an error.
	"""
	defcast error(reason) do
		# TODO handle the error (maybe log it?)
	end

	@doc """
	Called when the client disconnects, either gracefully (by sending a
	disconnect packet over the socket) or forcibly (when reading from the
	socket errors out).
	"""
	defcast disconnect do
		# TODO
	end

	@doc """
	Attempts to read a packet from the specified socket, then passes the packet
	to the specified client process as a message and resumes reading (if a
	packet was successfully read) or passes an error message to the client
	process and shuts down (if something went wrong).
	"""
	defp reader(client, socket) do
		case Alembic.Minecraft.Protocol.read_request(socket) do
			{:ok, request} ->
				client.request(request)
				reader(client, socket)
			{:error, :closed} ->
				client.disconnect
			{:error, reason} ->
				client.error(reason)
		end
	end
end
