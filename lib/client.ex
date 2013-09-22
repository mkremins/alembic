defmodule Alembic.Client do
	@moduledoc """
	Represents a client currently connected to the server. Responsible for
	reading requests from, and writing events to, the socket associated with
	that client.
	"""

	use ExActor

	defrecord State, name: "Stevesie", socket: nil

	@doc """
	Initializes a new client process, handing it control over the specified
	socket and setting up a new State record to hold information about the
	connected client.
	"""
	definit [socket, translator] do
		client = self
		reader = spawn fn ->
			reader(client, socket, translator)
		end
		Socket.TCP.process(socket, reader)
		State[socket: socket]
	end

	@doc """
	Called when the reader process successfully reads a request from the
	connected client.
	"""
	defcast request(request), state: state do
		# TODO
	end

	@doc """
	Called when the reader process encounters an error while attempting to read
	a request.
	"""
	defcast error(reason) do
		# TODO handle the error (maybe log it?)
	end

	@doc """
	Called when the client disconnects, either gracefully (by sending a
	disconnect request over the socket) or forcibly (when an attempt to read
	from the socket errors out).
	"""
	defcast disconnect do
		# TODO
	end

	@doc """
	Attempts to read a request from the specified socket using the specified
	protocol translator. If a request is successfully read, that request is
	then passed to the specified client process as a message; if something goes
	wrong, an error message is passed to the client process instead.
	"""
	defp reader(client, socket, translator) do
		case translator.read_request(socket) do
			{:ok, request} ->
				request(client, request)
				reader(client, socket, translator)
			{:error, :closed} ->
				disconnect(client)
			{:error, reason} ->
				error(client, reason)
		end
	end
end
