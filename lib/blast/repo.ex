defmodule Blast.Repo do
  use Ecto.Repo,
    otp_app: :blast,
    adapter: Ecto.Adapters.Postgres
end
