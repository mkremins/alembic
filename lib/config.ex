defmodule Alembic.Config do
	@moduledoc """
	Handles reading configuration options from file and parsing them into a
	convenient, accessible form.
	"""

	@doc """
	Evaluates the Elixir script file at the specified path, returning the
	configuration object the file defines.
	"""
	def read(filename) do
		filename = Path.expand(filename)
		case File.read(filename) do
			{:ok, binary} ->
				Code.eval_string(binary)
			{:error, reason} ->
				{:error, reason}
		end
	end
end
