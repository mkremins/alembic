defmodule Alembic.Mixfile do
  use Mix.Project

  def project do
    [ app: :alembic,
      version: "0.1.0",
      elixir: "~> 0.10.1",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    []
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [ {:socket, "0.1.3", [github: "meh/elixir-socket", tag: "v0.1.3"]} ]
  end
end
