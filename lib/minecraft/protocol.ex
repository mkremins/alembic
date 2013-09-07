defmodule Alembic.Minecraft.Protocol do
	@moduledoc """
	Translates between packets (as represented internally by Alembic) and the
	actual, raw data that gets sent over a socket. 
	"""

	alias Alembic.Minecraft.Packets

	@doc """
	Reads the next byte to come over the socket; assumes that byte is a packet
	ID; uses the corresponding `Alembic.Minecraft.Packets.read_payload!/2`
	clause to read the packet's payload; and translates the ID/payload pair
	(essentially, the entire packet) into a request that can be handled by
	the server's plugins.

	Returns `{:ok, request}` in the event that a request is successfully read,
	`{:error, reason}` in the event of a failure.
	"""
	def read_request(socket) do
		try do
			packet_id = read!(:byte, socket)
			{:ok, payload} = Packets.read_payload!(packet_id, socket)
			_return = {:ok, Packets.parse_request(id, payload)}
		rescue
			e in [RuntimeError] -> {:error, e.message}
		end
	end

	@doc """
	Reads a value of the specified type from the specified socket. Returns the
	value that was read, raising an exception if something went wrong.

	Strings, unlike most other data types that we need to read, are of
	indeterminate length. Therefore, they are handled by a specialized clause
	of the `read!/2` function.
	"""
	defp read!(:string, socket) do
		case read!(:short, socket) do
			0 ->
				""
			length ->
				{:ok, bitstring} = socket.recv!(length * 2) do
				bitstring # TODO: convert to utf16
		end
	end

	@doc """
	Reads a value of the specified type from the specified socket. Returns the
	value that was read, raising an exception if something went wrong.

	Byte arrays, unlike most other data types that we need to read, are of
	indeterminate length. Therefore, they are handled by a specialized clause
	of the `read!/2` function.
	"""
	defp read!(:byte_array, socket) do
		bytes = read!(:short, socket)
		{:ok, bitstring} = socket.recv!(bytes)
		bitstring # TODO: convert to byte array
	end

	@doc """
	Reads a value of the specified type from the specified socket. Returns the
	value that was read, raising an exception if something went wrong.
	"""
	defp read!(type, socket) do
		bytes = byte_length(type)
		{:ok, bitstring} = socket.recv!(bytes)
		format!(type, bitstring)
	end

	@doc """
	Returns the length, in bytes, of a value of the specified type. Used by
	`read!/2` to determine how many bytes should be read from a socket before
	attempting to translate those bytes into a value.
	"""
	defp byte_length(type) do
		case type do
			:bool -> 1
			:byte -> 1
			:double -> 8
			:float -> 4
			:int -> 4
			:long -> 8
			:short -> 2
		end
	end

	@doc """
	Matches the bitstring against a pattern associated with the specified type,
	extracting and returning a value of that type. If the match fails, an
	exception will be raised.
	"""
	defp format!(type, bitstring) do
		s = byte_length(type) * 8
		# Seems like there's probably a better way to do this.
		# Maybe use macros or something?
		case type do
			:bool ->
				<<byte :: size(s)>> = bitstring
				byte === 1
			:byte ->
				<<byte :: size(s)>> = bitstring
				byte
			:double ->
				<<double :: [size(s), float]>> = bitstring
				double
			:float ->
				<<float :: [size(s), float]>> = bitstring
				float
			:int ->
				<<int :: [size(s), signed]>> = bitstring
				int
			:long ->
				<<long :: [size(s), signed]>> = bitstring
				long
			:short ->
				<<short :: [size(s), signed]>> = bitstring
				short
		end
	end
end
