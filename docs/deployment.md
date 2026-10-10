# Deployment

The current live game is https://tjjpkxhe.idos.games/ and the platform page is
https://idosgames.com/app/TJJPKXHE/. Title ID: `TJJPKXHE`.

Version 6, build `bldefefadae4a464408831fc2ba2dc8a1d8`, was published on
2026-10-10 through the iDosGames MCP. The platform reported `Live` with no errors.

1. Install Godot 4.3 and its matching export templates.
2. Import `game/project.godot` and export the `Web` preset.
3. In `web/`, run `npm ci`, `npm run typecheck`,
   `node --test tests/holder-bonus.test.mjs`, and `npm run build`.
4. Run `web/scripts/package.ps1`. It packages the contents of `dist/` with the
   authenticated host at the ZIP root and removes the raw Godot HTML launcher.
5. For your own title, use iDosGames `begin_build_upload`, upload the ZIP to its
   returned URL, and use `finish_build_upload` to stage it for testing.
6. Verify the staged build, then publish it with `deploy=true`.

The live title uses `PlayAccess.Mode=Open`, no token access gates, and wallet
login enabled. `Blockchain.IframeConnectHosts` allows
`solana-rpc.publicnode.com` for the holder balance query. No CloudCode is required.
Changing another publisher's title requires their own authorization.

The package uses relative asset paths. Generated Godot exports, installed npm
dependencies, build archives, account sessions, and private credentials are not
committed to this repository.
