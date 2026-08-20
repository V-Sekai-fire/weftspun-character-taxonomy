import Config

# A release carries no config file, so it reads the database path from
# the environment at boot. The path must be on a volume that survives a
# redeploy, which is the one thing a file store asks of its host that a
# connection string did not.
if config_env() == :prod do
  config :character_taxonomy, CharacterTaxonomy.Repo,
    database: System.get_env("TAXONOMY_DB", "/data/character_taxonomy.db"),
    pool_size: String.to_integer(System.get_env("TAXONOMY_DB_POOL", "5"))
end
