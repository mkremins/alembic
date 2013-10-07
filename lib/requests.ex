defmodule Alembic.Request do
  @type t :: block | blocks | chat | custom | join | move | quit

  @typep block  :: {:block, block_data}
  @typep blocks :: {:blocks, [block_data]}
  @typep chat   :: {:chat, String.t}
  @typep custom :: {:custom, {atom, any}}
  @typep join   :: {:join, String.t}
  @typep move   :: {:move, {float, float, float}}
  @typep quit   :: {:quit, String.t}

  @typep block_data :: {{integer, integer, integer}, byte}
end
