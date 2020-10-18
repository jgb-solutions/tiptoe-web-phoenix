defmodule TipToe.Repo do
  use Ecto.Repo,
    otp_app: :tip_toe,
    adapter: Ecto.Adapters.Postgres
end
