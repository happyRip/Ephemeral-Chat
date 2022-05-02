defmodule EphemeralChat.Repo do
  use Ecto.Repo,
    otp_app: :ephemeral_chat,
    adapter: Ecto.Adapters.Postgres
end
