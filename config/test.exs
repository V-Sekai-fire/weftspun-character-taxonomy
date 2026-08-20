import Config

# A file, so a test run needs no server started first. The sandbox pool
# still applies: it is the adapter's transaction isolation, not a
# PostgreSQL feature.
config :character_taxonomy, CharacterTaxonomy.Repo,
  database:
    System.get_env("CHARACTER_TAXONOMY_DB", Path.expand("../character_taxonomy_test.db", __DIR__)),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 5

config :logger, level: :warning
