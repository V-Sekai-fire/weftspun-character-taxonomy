# weftspun-character-taxonomy

The character trait taxonomy as a small Elixir service: a JSON route, a static randomizer page and an MCP server.

## Use

The service keeps the taxonomy of character traits in SQLite so a created id or a widened numeric range survives a restart. Its MCP tools resolve traits, widen numeric ranges, return the whole taxonomy, and run taskweft's planner over the embedded character concept domain. [RFD 1065](https://github.com/V-Sekai-fire/manuals-weftspun/tree/main/rfd/1065-taskweft-domain-schema-in-etnf) owns the taxonomy's schema.

## Build and run

```sh
mix deps.get && mix ecto.setup
iex -S mix
```

`mix test` runs the suite.

## Licence

MIT. See [LICENSE](LICENSE).
