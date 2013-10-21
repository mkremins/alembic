defmodule Alembic.Mixfile do
  use Mix.Project

  def project do
    [ app: :alembic,
      version: "0.1.0-dev",
      name: "Alembic",
      source_url: "https://github.com/mkremins/alembic",
      elixir: "~> 0.10.3",
      deps: deps ]
  end

  def application do
    [ applications: [:socket],
      mod: {Alembic, []} ]
  end

  defp deps do
    [ {:exactor, "0.1",       github: "sasa1977/exactor"},
      {:socket,  "0.2.0-dev", github: "meh/elixir-socket"} ]
  end
end
