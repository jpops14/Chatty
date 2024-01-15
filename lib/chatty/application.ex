defmodule Chatty.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ChattyWeb.Telemetry,
      Chatty.Repo,
      {DNSCluster, query: Application.get_env(:chatty, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Chatty.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Chatty.Finch},
      # Start a worker by calling: Chatty.Worker.start_link(arg)
      # {Chatty.Worker, arg},
      # Start to serve requests, typically the last entry
      ChattyWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chatty.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChattyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
