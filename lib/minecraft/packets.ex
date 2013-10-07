defmodule Alembic.Translator.Minecraft.Packets do
  @moduledoc """
  Contains Elixir-ized definitions of each useful client->server packet type,
  including the data types to expect when attempting to decode the payload of
  a packet of that type.
  """

  import Alembic.Translator.Minecraft.Macros

  defpacket 0x00, [ keepalive_id: :int ]

  defpacket 0x02, [ protocol_version: :byte,
                    username: :string,
                    host: :string,
                    port: :int ]

  defpacket 0x03, [ json: :string ]

  defpacket 0x07, [ player_eid: :int,
                    target_eid: :int,
                    left_click?: :bool ]

  defpacket 0x0a, [ on_ground?: :bool ]

  defpacket 0x0b, [ x: :double,
                    y: :double,
                    stance: :double,
                    z: :double,
                    on_ground?: :bool ]

  defpacket 0x0c, [ yaw: :float,
                    pitch: :float,
                    on_ground?: :bool ]

  defpacket 0x0d, [ x: :double,
                    y: :double,
                    stance: :double,
                    z: :double,
                    yaw: :float,
                    pitch: :float,
                    on_ground?: :bool ]

  defpacket 0x0e, [ action: :byte,
                    x: :int,
                    y: :byte,
                    z: :int,
                    face: :byte ]

  defpacket 0x0f, [ x: :int,
                    y: :ubyte,
                    z: :int,
                    direction: :byte,
                    held_item: :slot,
                    cursor_x: :byte,
                    cursor_y: :byte,
                    cursor_z: :byte ]

  defpacket 0x10, [ slot_id: :short ]

  defpacket 0x12, [ entity_id: :int,
                    animation: :byte ]

  defpacket 0x13, [ entity_id: :int,
                    action: :byte,
                    horse_jump_boost: :int ]

  defpacket 0x1b, [ sideways: :float,
                    forwards: :float,
                    jump?: :bool,
                    unmount?: :bool ]

  defpacket 0x65, [ window_id: :byte ]

  defpacket 0x66, [ window_id: :byte,
                    slot_id: :short,
                    left_click?: :bool,
                    action_number: :short,
                    mode: :byte,
                    clicked_item: :slot ]

  defpacket 0x6a, [ window_id: :byte,
                    action_number: :short,
                    accepted?: :bool ]

  defpacket 0x6b, [ slot_id: :short,
                    clicked_item: :slot ]

  defpacket 0x6c, [ window_id: :byte,
                    enchantment: :byte ]

  defpacket 0x82, [ x: :int,
                    y: :short,
                    z: :int,
                    line_1: :string,
                    line_2: :string,
                    line_3: :string,
                    line_4: :string ]

  defpacket 0xca, [ flags: :byte,
                    fly_speed: :float,
                    walk_speed: :float ]

  defpacket 0xcb, [ text: :string ]

  defpacket 0xcc, [ locale: :string,
                    view_distance: :byte,
                    chat_flags: :byte,
                    difficulty: :byte,
                    show_capes?: :bool ]

  defpacket 0xcd, [ status: :byte ]

  defpacket 0xfa, [ channel: :string,
                    message: :byte_array ]

  defpacket 0xfc, [ shared_secret: :byte_array,
                    verify_token: :byte_array ]

  defpacket 0xfe, [ ping: :byte ]

  defpacket 0xff, [ reason: :string ]
end
