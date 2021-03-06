defmodule ExchangeApiWeb.Router do
  use ExchangeApiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ExchangeApiWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug ExchangeApi.Guardian.AuthPipeline
  end

  scope "/", ExchangeApiWeb do
    # Auth
    pipe_through [:api, :jwt_authenticated]
    # pipe_through :api

    scope "/ticker/:ticker" do
      scope "/orders" do
        get "/open", Api.OrderController, :index_open
        get "/buy_side", Api.OrderController, :count_buy_side
        get "/sell_side", Api.OrderController, :count_sell_side
        get "/spread", Api.OrderController, :spread
        get "/highest_bid_price", Api.OrderController, :highest_bid_price
        get "/highest_bid_volume", Api.OrderController, :highest_bid_volume
        get "/lowest_ask_price", Api.OrderController, :lowest_ask_price
        get "/highest_ask_volume", Api.OrderController, :highest_ask_volume
      end

      scope "/traders/:trader_id" do
        resources "/orders", Api.TraderOrdersController, only: [:index, :create, :delete] do
          delete "/delete", Api.TraderOrdersController, :delete
          get "/completed", Api.TraderOrdersController, :index_completed
        end
      end
    end
  end

  scope "/api/v1", ExchangeApiWeb do
    pipe_through :api

    post "/access", UserController, :create
  end

  scope "/home", ExchangeApiWeb do
    pipe_through :browser

    live "/ticker/:ticker", OrderBookLive, :get
    live "/ticker/:ticker/completed", CompletedTradesLive, :get
    live "/ticker/:ticker/order/:order_id", OrderLive, :get

    get "/", HomeController, :home
    delete "/ticker/:ticker/order/:order_id/cancel", OrderController, :delete
    get "/ticker/:ticker/completed/trade/:trade_id", TradeController, :get
    post "/ticker/:ticker/create_order", OrderController, :create
    get "/ticker/:ticker/create_order", OrderController, :get
  end

  # Other scopes may use custom stacks.
  # scope "/api", ExchangeWeb do
  #   pipe_through :api
  # end

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
      live_dashboard "/dashboardz", metrics: ExchangeApiWeb.Telemetry
    end
  end
end
