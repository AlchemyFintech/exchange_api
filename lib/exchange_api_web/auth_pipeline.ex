defmodule ExchangeApi.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :exchange_api,
    module: ExchangeApi.Guardian,
    error_handler: ExchangeApi.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
