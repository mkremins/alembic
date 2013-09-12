defmodule Alembic.Translator do
	@moduledoc """
	Defines the Translator behaviour, implementations of which are used to
	translate packets to and from standardized Alembic-internal requests and
	events on behalf of clients of various types.
	"""

	use Behaviour

	@doc """
	Reads a packet from the specified socket and interprets it as a request
	that can be dispatched by the event manager and handled by plugins. Returns
	`{:ok, request}` on success, `{:error, reason}` on failure.
	"""
	defcallback read_request(socket) :: {:ok, request} | {:error, reason}

	@doc """
	Writes a packet to the specified socket conveying the meaning of the
	specified event. Returns `:ok` on success, `{:error, reason}` on failure.
	"""
	defcallback write_event(socket, event) :: :ok | {:error, reason}
end
