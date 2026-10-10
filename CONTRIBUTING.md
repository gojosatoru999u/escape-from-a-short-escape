# Contributing

Keep the game free to enter and keep the holder bonus optional. Do not add
payments, private keys or authoritative prize claims to the browser.

For Godot changes, use Godot 4.3 and verify the Web export. For host changes,
run `npm run typecheck` and `node --test tests/holder-bonus.test.mjs` in `web/`.
Run the complete browser game when changing the host bridge or bonus UI.

Preserve upstream attribution and bundled licenses. Generated exports,
`node_modules`, `.godot`, `.env` files and credentials must stay out of commits.
