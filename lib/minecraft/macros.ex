defmodule Alembic.Minecraft.Macros do
	@moduledoc """
	Macros used by other modules in the `Alembic.Minecraft` namespace.
	"""

	alias Alembic.Minecraft.Protocol

	@doc """
	Defines a packet handler function for the specified packet ID that will
	read each of the specified types from the socket in order. The handler
	function will return a keyword list mapping the names specified in `types`
	to the actual values that were read from the socket, raising an exception
	in the event that something goes wrong.
	"""
	defmacro defpacket(id, types) do
		quote do
			def read_payload!(unquote(id), socket) do
				payload = Keyword.new
				lc {key, type} inlist unquote(types) do
					Keyword.put(payload, key, Protocol.read!(type, socket))
				end
				_return = {:ok, payload}
			end
		end
	end

	@doc """
	Defines a parser function for the specified packet ID that will parse the
	payload of a packet with that ID and return a request object to be handled
	by plugins. The parser function will receive as its `payload` argument the
	keyword list returned by the `read_payload!/2` clause corresponding to the
	specified packet ID.
	"""
	defmacro defparser(id, code) do
		quote do
			def parse_request(unquote(id), payload) do
				unquote(code)
			end
		end
	end
end
