defmodule Alembic.Translator.Minecraft.Macros do
  @moduledoc """
  Macros used by other modules in the `Alembic.Translator.Minecraft` module
  namespace.
  """

  alias Alembic.Translator.Minecraft, as: Translator

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
        Enum.each unquote(types), fn({key, type}) ->
          Keyword.put(payload, key, Translator.read!(type, socket))
        end
        {:ok, payload}
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
