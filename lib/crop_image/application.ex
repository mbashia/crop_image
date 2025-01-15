defmodule CropImage.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      CropImageWeb.Telemetry,
      # Start the Ecto repository
      CropImage.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: CropImage.PubSub},
      # Start Finch
      {Finch, name: CropImage.Finch},
      # Start the Endpoint (http/https)
      CropImageWeb.Endpoint
      # Start a worker by calling: CropImage.Worker.start_link(arg)
      # {CropImage.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CropImage.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CropImageWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
