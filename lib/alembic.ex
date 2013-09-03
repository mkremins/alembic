defmodule Alembic do
	@moduledoc """
	Main application entry point.
	"""

	use Application.Behaviour

	@doc """
	Starts the application.
	"""
	def start(_type, _args) do
		Alembic.Supervisor.start_link()
	end
end
