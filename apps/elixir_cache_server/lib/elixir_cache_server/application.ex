defmodule ElixirCacheServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "4040")

    children = [
      {Task.Supervisor, name: ElixirCacheServer.TaskSupervisor},
      Supervisor.child_spec({Task, fn -> ElixirCacheServer.accept(port) end}, restart: :permanent)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirCacheServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
