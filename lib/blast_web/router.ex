defmodule BlastWeb.Router do
  use BlastWeb, :router

  pipeline :browser do
    plug CORSPlug, origin: "*"
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
  end

  pipeline :game do
    plug :put_layout, {BlastWeb.LayoutView, :game}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BlastWeb do
    pipe_through :browser

    get "/", GameLaunchController, :index
    post "/", GameLaunchController, :create
  end

  scope "/game", BlastWeb do
    pipe_through [:browser, :game]
    # match :get, "/:game_id", GameController, :show_join_game
    # match :post, "/:game_id", GameController, :join_game

    get "/:game_id", GameController, :show
    post "/:game_id", GameController, :join
  end
end
