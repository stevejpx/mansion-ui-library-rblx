# Tooling

- `generate.mjs` turns the typed snapshot into chunked Luau data, an asset manifest and style/coverage reports.
- `download-assets.mjs` downloads public original image bytes and records each failure. No cookies, credentials or access-control workarounds are used.
- `gallery.mjs` creates the searchable offline HTML reference.
- `verify.mjs` validates IDs/parents, manifests, local image bytes, chunk counts and complete source method-name coverage. It also regenerates `docs/API.md`.
- `export-studio.luau` is the read-only extraction command used against the provided place. Run with Studio plugin/command privileges. It yields in batches, reads UI properties, destroys its detached default instances, and leaves the compressed export in `_G.MansionUIExport`. It does not parent new instances into the place or run source-place scripts. The stored string is base64-encoded Zstandard-compressed UTF-8 snapshot JSON. Copy it through your Studio integration, decode base64, decompress Zstandard, and write `reference/snapshot.json` before running the generators. Its property list is pinned to the extraction's API metadata; re-check against the current engine API before extending it.

Template exports are data, not a backup of the full place. No source game scripts are included. Native reference screenshots were captured in the generated demo place using the Studio integration; the source place remained unchanged.
