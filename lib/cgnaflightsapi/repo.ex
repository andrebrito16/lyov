defmodule Cgnaflightsapi.Repo do
  use Ecto.Repo,
    otp_app: :cgnaflightsapi,
    adapter: Ecto.Adapters.Postgres
end
