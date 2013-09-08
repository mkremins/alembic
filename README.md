Alembic
========================================

Alembic is a bare-bones, concurrent and heavily extensible server for multiplayer voxel games. It's _also_ an excuse for me to experiment with the [Elixir](http://elixir-lang.org) programming language and the coroutine-esque concurrency model favored by the BEAM (Erlang) VM atop which Elixir resides.

Features
----------------------------------------

  * Extensible – most functionality is implemented inside plugins
  * Generic – write your own multiplayer voxel game without touching any non-plugin code
  * Idiomatic – wherever possible, I'm adhering to Elixir and Erlang/OTP best practices
  * Well-documented – anyone with a working knowledge of Elixir should be able to navigate the codebase
  * Protocol-agnostic – client-specific code is confined to sealed-off adapter modules
  * Modular – if I _can_ split something off into its own library, I probably _will_

Thanks to...
----------------------------------------

  * The [#mcdevs](http://mcdevs.org) folks, for maintaining the most exhaustive [documentation of the Minecraft protocol](http://wiki.vg/Protocol) I could possibly hope for.
  * [clonejo](http://github.com/clonejo), for publishing the [mc-erl](http://github.com/clonejo/mc-erl) source code. mc-erl's architecture served as a partial reference to me when I was just starting out.
  * [mrshankly](http://github.com/mrshankly), for publishing the [Mambo](http://github.com/mrshankly/mambo) source code. Mambo's extensibility model served as the primary inspiration for Alembic's plugin architecture.

License
----------------------------------------

[MIT License](http://opensource.org/licenses/MIT). Remix to your heart's content.
