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
	configuration object the file defines. If the file does not exist, the
	default configuration object will be written to that path and returned.
	"""
	defp read(filename) do
		filename = Path.expand(filename)
		case File.read(filename) do
			{:ok, binary} ->
				Code.eval_string(binary) |> elem(0)
			{:error, :enoent} ->
				write(filename, defaults)
			{:error, reason} ->
				{:error, format_error(reason)}
		end
	end

	@doc """
	Writes the specified configuration object to the specified path as an
	Elixir script file.
	"""
	defp write(filename, config) do
		filename = Path.expand(filename)
		case File.write(filename, inspect config) do
			:ok ->
				config
			{:error, reason} ->
				{:error, format_error(reason)}
		end
	end

	@doc """
	Returns the default configuration object.
	"""
	defp defaults do
		[ host: "127.0.0.1",
	      port: 25565,
	      plugins: ["./plugins"] ]
	end

	@doc """
	Formats the reason returned with a filesystem error for improved
	readability.
	"""
	defp format_error(reason) do
		:file.format_error(reason)
	end
end