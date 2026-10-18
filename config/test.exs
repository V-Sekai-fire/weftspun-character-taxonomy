import Config

# A file, so a test run needs no server started first. The sandbox pool
# still applies: it is the adapter's transaction isolation, not a
# PostgreSQL feature. With TAXONOMY_WEFTFDB_EXTENSION set the database is
# a weft_fdb one, which admits one connection.
weftfdb = System.get_env("TAXONOMY_WEFTFDB_EXTENSION")

config :character_taxonomy,
       CharacterTaxonomy.Repo,
       [
         database:
           System.get_env(
             "CHARACTER_TAXONOMY_DB",
             Path.expand("../character_taxonomy_test.db", __DIR__)
           ),
         migration_lock: false,
         # The migrator runs each migration in its own process, which the sandbox
         # refuses on a one-connection weft_fdb database; CI migrates with a plain pool.
         pool:
           if(System.get_env("TAXONOMY_MIGRATION_POOL"),
             do: DBConnection.ConnectionPool,
             else: Ecto.Adapters.SQL.Sandbox
           )
       ] ++
         if(weftfdb,
           do: [
             pool_size: 1,
             journal_mode: :memory,
             locking_mode: :exclusive,
             # Sandboxed async tests queue on the one connection; wait rather than drop.
             queue_target: 5_000,
             queue_interval: 30_000
           ],
           else: [pool_size: 5]
         )

config :logger, level: :warning
