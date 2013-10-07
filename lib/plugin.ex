defmodule Alembic.Plugin.Behaviour do
  @moduledoc """
  Defines the callback functions that the main callback module of each
  Alembic plugin is expected to implement and provides a `__using__/2` helper
  macro that plugin authors can use to define fallback implementations of
  several of these callbacks.
  """

  use Behaviour

  alias Alembic.Client
  alias Alembic.Request

  @doc false
  defmacro __using__(_module, _opts) do
    quote do
      @behaviour Alembic.Plugin.Behaviour

      @doc """
      Fallback clause of the expected callback function `handle/2`. Used
      to ensure that a well-defined plugin's callback module will not
      throw a missing function clause error when this callback is invoked
      by the server's plugin manager.
      """
      def handle(_request, _client) do
        :continue
      end

      @doc """
      Fallback clause of the expected callback function `screen/2`. Used
      to ensure that a well-defined plugin's callback module will not
      throw a missing function clause error when this callback is invoked
      by the server's plugin manager.
      """
      def screen(_request, _client) do
        :ignore
      end
    end
  end

  @doc """
  Returns the current plugin's manifest. A valid plugin manifest is a keyword
  list with the following key-value pairs:

  * `name`: the name of the plugin, as a string
  * `version`: the plugin's SemVer-compliant version number, as a string
  """
  defcallback alembic_plugin :: [name: String.t, version: String.t]

  @doc """
  Invoked by the server's plugin manager when it is this plugin's turn to
  handle the specified request. Note that one or more other plugins may have
  already been given an opportunity to handle this request by the time this
  callback is invoked.

  This function should return either the atom `:continue` (if the request
  should also be passed down the line for the plugin with the next-highest
  handle priority to handle) or the atom `:consume` (if no further plugins
  should be allowed to handle the request).
  """
  defcallback handle(Request.t, pid) :: :continue | :consume

  @doc """
  Invoked by the server's plugin manager each time a new request is
  submitted. The value returned by a plugin's implementation of this function
  when passed a particular request is used to determine when, if ever, the
  plugin will be given an opportunity to handle that request.

  This function should return either an integer (with a higher integer
  indicating a stronger interest in being the first plugin to handle the
  specified request) or the atom `:ignore` (indicating that this plugin has
  no interest in handling the request at all).
  """
  defcallback screen(Request.t, pid) :: integer | :ignore
end
