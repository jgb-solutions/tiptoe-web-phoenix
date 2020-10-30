defmodule TipToeWeb.Router do
  use TipToeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TipToeWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug CORSPlug, origin: "*"
    plug :accepts, ["json"]
  end

  pipeline :graphql do
    plug TipToe.Context
  end

  scope "/", TipToeWeb do
    pipe_through :browser

    live "/", PageLive, :index
  end

  scope "/api" do
    pipe_through :api

    scope "/graphql" do
      pipe_through :graphql

      if Mix.env() == :dev do
        forward "/playground", Absinthe.Plug.GraphiQL,
          schema: TipToeWeb.GraphQL.Schema,
          interface: :playground,
          socket: TipToeWeb.UserSocket
      end

      forward "/", Absinthe.Plug, schema: TipToeWeb.GraphQL.Schema
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: TipToeWeb.Telemetry
    end
  end
end
