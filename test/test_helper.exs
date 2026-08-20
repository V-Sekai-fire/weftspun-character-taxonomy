# Database tests need no server. The database is a file, created on
# demand, so `mix test` is the whole instruction.
Ecto.Adapters.SQL.Sandbox.mode(CharacterTaxonomy.Repo, :manual)

ExUnit.start()
