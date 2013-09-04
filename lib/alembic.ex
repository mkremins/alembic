defmodule Alembic do
	@moduledoc """
	Main application entry point.
	"""

	use Application.Behaviour

	@doc """
	Starts the application.
	"""
	def start(_type, args) do
		Alembic.Supervisor.start_link(args)
	end
end
