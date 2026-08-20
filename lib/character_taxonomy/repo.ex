# SPDX-License-Identifier: MIT
# Copyright (c) 2026 K. S. Ernest (iFire) Lee

defmodule CharacterTaxonomy.Repo do
  @moduledoc """
  The database connection for this service, on its own SQLite file.

  RFD 0020 picked CockroachDB and RFD 0067 kept it. Both are retracted.
  The taxonomy is catalog facts at human scale, so a file the service
  owns outright is the whole requirement, and a cluster was answering a
  question this service does not ask.

  RFD 0065's taxonomy must survive a restart and a redeploy, so it
  is not `CharacterTaxonomy.Taxonomy`'s Agent state alone. That Agent
  stays as the read-path cache. This repo is the write-through and
  the boot-time hydration source.
  """

  use Ecto.Repo,
    otp_app: :character_taxonomy,
    adapter: Ecto.Adapters.SQLite3
end
