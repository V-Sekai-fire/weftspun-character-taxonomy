# SPDX-License-Identifier: MIT
# Copyright (c) 2026 K. S. Ernest (iFire) Lee

defmodule CharacterTaxonomy.Repo do
  @moduledoc """
  The database connection for this service: SQLite.

  With `:weftfdb_extension` configured, the database is a
  `file:<name>?vfs=weft_fdb` URI whose pages live in FoundationDB
  (datasource-store's `weftfdb` extension), and the pool holds one
  connection because every open of a weft_fdb database takes its fence.
  Without it, a plain file.

  RFD 0065's taxonomy must survive a restart and a redeploy, so it
  is not `CharacterTaxonomy.Taxonomy`'s Agent state alone. That Agent
  stays as the read-path cache. This repo is the write-through and
  the boot-time hydration source.
  """

  use Ecto.Repo,
    otp_app: :character_taxonomy,
    adapter: Ecto.Adapters.SQLite3

  @impl true
  def init(_context, config) do
    case Application.get_env(:character_taxonomy, :weftfdb_extension) do
      nil ->
        {:ok, config}

      path ->
        with :ok <- load_extension(path) do
          {:ok, Keyword.put(config, :pool_size, 1)}
        end
    end
  end

  # The weft_fdb VFS registers process-wide, so it is loaded once on a throwaway connection.
  defp load_extension(path) do
    key = {__MODULE__, :weftfdb, path}

    if :persistent_term.get(key, false) do
      :ok
    else
      {:ok, conn} = Exqlite.Sqlite3.open(":memory:")

      try do
        with :ok <- Exqlite.Sqlite3.enable_load_extension(conn, true),
             :ok <-
               Exqlite.Sqlite3.execute(
                 conn,
                 "SELECT load_extension('#{String.replace(path, "'", "''")}')"
               ) do
          :persistent_term.put(key, true)
          :ok
        end
      after
        Exqlite.Sqlite3.close(conn)
      end
    end
  end
end
