defmodule Alembic.Minecraft.Packets do
	@moduledoc """
	Contains Elixir-ized definitions of each useful client->server packet type,
	including the data types to expect when attempting to decode the payload of
	a packet of that type.
	"""

	import Alembic.Minecraft.Macros

	defpacket 0x00, [ keepalive_id: :int ]

	defpacket 0x02, [ protocol_version: :byte,
					  username: :string,
					  host: :string,
					  port: :int ]

	defpacket 0x03, [ json: :string ]

	defpacket 0x0b, [ x: :double,
					  y: :double,
					  stance: :double,
					  z: :double,
					  on_ground?: :bool ]

	defpacket 0x0d, [ x: :double,
					  y: :double,
					  stance: :double,
					  z: :double,
					  yaw: :float,
					  pitch: :float,
					  on_ground?: :float ]
end
