defmodule BlastWeb.Router do
  use BlastWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BlastWeb do
    pipe_through :browser

    get "/", GameLaunchController, :index
    post "/", GameLaunchController, :create

    match :get, "/game/:token", GameController, :join_game
  end

  # Other scopes may use custom stacks.
  # scope "/api", BlastWeb do
  #   pipe_through :api
  # end
end
