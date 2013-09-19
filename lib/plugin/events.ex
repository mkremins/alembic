defmodule Alembic.EventManager do
	@moduledoc """
	The server's event manager. Allows plugins to interface with one another,
	and with the server internals, by handling standard event types and firing
	new events as desired.
	"""

	@doc false
	def start_link do
		:gen_event.start_link({:local, __MODULE__})
	end

	@doc """
	Fires the specified event, giving each loaded plugin a chance to handle
	said event. Returns `:ok` on success.
	"""
	def notify(event_type, event_data) do
		:gen_event.notify(__MODULE__, {event_type, event_data})
	end

	@doc """
	Registers the specified module to receive notifications of events
	dispatched by the event manager. Returns `:ok` on success.
	"""
	def add_handler(module) do
		:gen_event.add_handler(__MODULE__, module, [])
	end
end
