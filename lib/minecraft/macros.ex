defmodule Alembic.Minecraft.Macros do
	@moduledoc """
	Macros used by other modules in the `Alembic.Minecraft` namespace.
	"""

	alias Alembic.Minecraft.Protocol

	@doc """
	Defines a packet handler function for the specified packet ID that will
	read each of the specified types from the socket in order.
	"""
	defmacro defpacket(id, types) do
		quote do
			def read_packet(unquote(id), socket) do
				packet = Keyword.new
				lc {key, type} inlist unquote(types) do
					Keyword.put(packet, key, Protocol.read(type, socket))
				end
				_return = packet
			end
		end
	end
end
