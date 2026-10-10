# Architecture

`game/` contains the Godot 4.3 project and bundled assets. `web/` contains the
iDosGames application shell and the `escape-island` module. Godot Web exports
are generated under `web/public/game/` and are served together with the host.

The host authenticates the player before mounting Godot. `PlatformBridge.gd`
exchanges gameplay state and the selected bonus tool with the host. The scene
pauses while the bonus dialog is open and resumes when it closes.

`holderBonus.ts` gets confirmed linked Solana wallet addresses from the SDK,
derives the main SPL Token account for ESCAPE, and queries finalized
`getAccountInfo` through `https://solana-rpc.publicnode.com`. It validates the
token program owner, account type/size, mint, wallet owner, decimals and raw
integer amount. A missing account means zero balance; an RPC failure is shown
as an error and does not qualify the player.

Claiming rechecks the balance and the active game run, introduction completion,
free inventory space and previous choice. Godot delivers the selected tool once.
Opening the dialog or switching wallets does not permit another choice.

## Trust boundary

Only addresses returned for the authenticated player are offered in the normal
UI. Linking requires a signed message, not a payment transaction. There are no
private keys in the project, and the application never sends a payment.

The bonus and game inventory live on the client. A modified client can bypass
the checks. This design suits an optional single-player gameplay bonus and is
not suitable for tradable items, cash prizes, or authoritative rewards. Such
features would require protected server verification.

## Known limitations

- The free RPC checks the main associated token account, not every token account.
- Wallet extension signing requires a supported browser or wallet browser.
- Human wallet linking/signature testing remains outstanding.
- Public RPC rate limits or outages can temporarily prevent bonus claims.
- iDosGames account services require an internet connection.

There is no custom Solana program, paid checkout, buyback service, or game backend
in this repository.
