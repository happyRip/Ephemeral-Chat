defmodule EpherimealChat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      EpherimealChatWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: EpherimealChat.PubSub},
      # Start the Endpoint (http/https)
      EpherimealChatWeb.Endpoint,
      EpherimealChatWeb.Presence
      # Start a worker by calling: EpherimealChat.Worker.start_link(arg)
      # {EpherimealChat.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EpherimealChat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EpherimealChatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
