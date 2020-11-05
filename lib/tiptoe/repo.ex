defmodule TipToe.Repo do
  use Ecto.Repo,
    otp_app: :tiptoe,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 20
end
