import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :ephemeral_chat, EphemeralChat.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "ephemeral_chat_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ephemeral_chat, EphemeralChatWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "QolbUIr4c4vsB6Q8L7dpmIqt8aVMNzt/I8YdyOjv2jTLnFxrCQTE1geanLkvwrTx",
  server: false

# In test we don't send emails.
config :ephemeral_chat, EphemeralChat.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
