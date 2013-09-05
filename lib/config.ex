defmodule Alembic.Config do
	@moduledoc """
	Handles reading configuration options from file and parsing them into a
	convenient, accessible form.
	"""

	use ExActor, export: :singleton

	@doc """
	Initializes the configuration object with the contents of the
	`#{ALEMBIC_ROOT}/config.exs` file on disk.
	"""
	def init(_args) do
		initial_state(read "./config.exs")
	end

	@doc """
	Returns the initialized configuration object, from which the caller is then
	free to read individual options as desired.
	"""
	defcall get, state: config do
		config
	end

	@doc """
	Evaluates the Elixir script file at the specified path, returning the
	configuration object the file defines.
	"""
	defp read(filename) do
		filename = Path.expand(filename)
		case File.read(filename) do
			{:ok, binary} ->
				Code.eval_string(binary) |> elem(0)
			{:error, reason} ->
				{:error, reason}
		end
	end
end
