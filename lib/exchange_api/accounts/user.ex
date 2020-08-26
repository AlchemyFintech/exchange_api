defmodule ExchangeApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:email, :string)
    field(:jwt, :string)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :jwt])
    |> validate_required([:email])
    |> unique_constraint(:email)
  end
end
