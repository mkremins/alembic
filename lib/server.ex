defmodule Alembic.Server do
	use GenServer.Behaviour

	def init({host, port}) do
		listening = Socket.TCP.listen! local: [address: host, port: port]
		spawn fn ->
			acceptor(listening, self)
		end
	end

	def handle_cast({:connect, socket}, state) do
		client_pid = Alembic.ClientSupervisor.spawn_client(socket)
		Socket.TCP.process(socket, client_pid)
		{:noreply, state}
	end

	defp acceptor(listening, pid) do
		case Socket.TCP.accept!(listening) do
			{:ok, socket} ->
				:gen_server.cast(pid, {:connect, socket})
				acceptor(listening, pid)
			error ->
				error
		end
	end
end
