defmodule ExchangeApiWeb.OrderLive do
  use ExchangeApiWeb, :live_view
  alias ExchangeApiWeb.Ticker

  def mount(%{"order_id" => order_id, "ticker" => ticker}, _session, socket) do
    {:ok, tick} = Ticker.get_ticker(ticker)
    {:ok, order} = Exchange.open_orders_by_id(tick, order_id)

    {:ok,
     assign(socket,
       order: order
     )}
  end
end
