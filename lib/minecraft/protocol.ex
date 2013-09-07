defmodule Alembic.Minecraft.Protocol do
	@moduledoc """
	Translates between packets (as represented internally by Alembic) and the
	actual, raw data that gets sent over a socket. 
	"""

	alias Alembic.Minecraft.Packets

	@doc """
	Reads the next byte to come over the socket, assumes it's a packet ID, and
	then delegates reading to the `read_packet/2` function clause corresponding
	to that ID.

	Returns `{:ok, request}` in the event of a successful packet read,
	`{:error, reason}` in the event of a failure.
	"""
	def read_packet(socket) do
		case read(:byte, socket) do
			{:error, reason} ->
				{:error, reason}
			packet_id -> 
				case Packets.read_packet(packet_id, socket) do
					{:error, reason} ->
						{:error, reason}
					request ->
						{:ok, request}
				end
		end
	end

	####################################
	# generic data type definitions
	####################################

	@doc """
	Strings, unlike other data types that we need to read, are of indeterminate
	length. Therefore, we use a special `read/2` clause to handle strings and
	strings alone.
	"""
	defp read(:string, socket) do
		case read(:short, socket) do
			0 ->
				""
			length when is_integer(length) ->
				case socket.recv(length * 2) do
					{:ok, bitstring} ->
						bitstring # TODO: convert to utf-16
					error ->
						error
				end
			error ->
				error
		end
	end

	@doc """
	Reads a value of the specified type from the specified socket.
	"""
	defp read(type, socket) do
		bytes = byte_length(type)
		case socket.recv(bytes) do
			{:ok, bitstring} ->
				format(type, bitstring)
			{:error, reason} ->
				{:error, reason} # TODO: raise exception
		end
	end

	@doc """
	Returns the length, in bytes, of a value of the specified type. Used by
	`read/2` to determine how many bytes should be read from a socket before
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
	extracting and returning a value of that type.
	"""
	defp format(type, bitstring) do
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
