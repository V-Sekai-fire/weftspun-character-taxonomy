import Config

# TAXONOMY_WEFTFDB_EXTENSION keeps the database's pages in FoundationDB
# (datasource-store's weftfdb); the default database is then a weft_fdb URI.
extension = System.get_env("TAXONOMY_WEFTFDB_EXTENSION")

if extension do
  config :character_taxonomy, :weftfdb_extension, extension
end

if config_env() == :prod do
  default_db =
    if extension,
      do: "file:character_taxonomy.v1?vfs=weft_fdb",
      else: "/data/character_taxonomy.db"

  config :character_taxonomy, CharacterTaxonomy.Repo,
    database: System.get_env("TAXONOMY_DB", default_db),
    pool_size: String.to_integer(System.get_env("TAXONOMY_DB_POOL", "5"))
end
