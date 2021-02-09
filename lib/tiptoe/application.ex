defmodule TipToe.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # Dotenv config
    unless Application.get_env(:tiptoe, :environment) == :prod do
      Dotenv.load()
      Mix.Task.run("loadconfig")
    end

    # end Dotenv config

    children = [
      # Start the Ecto repository
      TipToe.Repo,
      # Start the Telemetry supervisor
      TipToeWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: TipToe.PubSub},
      TipToeWeb.Presence,
      # Start the Endpoint (http/https)
      TipToeWeb.Endpoint,
      # Start a worker by calling: TipToe.Worker.start_link(arg)
      # {TipToe.Worker, arg}
      {Absinthe.Subscription, TipToeWeb.Endpoint}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TipToe.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TipToeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
