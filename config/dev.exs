import Config

# A file beside the project. Nothing to start, and nothing to be running
# before `mix ecto.migrate` works.
config :character_taxonomy, CharacterTaxonomy.Repo,
  database:
    System.get_env("CHARACTER_TAXONOMY_DB", Path.expand("../character_taxonomy_dev.db", __DIR__)),
  pool_size: 5
