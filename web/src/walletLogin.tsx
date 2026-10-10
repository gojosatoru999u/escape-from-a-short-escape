import { LazySolanaWalletLogin as LazyWalletLogin } from "@idosgames/wallet/react/lazy";
import type { RenderLinkWallet, RenderWalletLogin } from "@idosgames/app-shell";
import { isEmbeddedInPlatform } from "@idosgames/wallet";
import { InjectedSolanaLogin } from "./InjectedSolanaLogin";
import { ENV_WALLETCONNECT_PROJECT_ID } from "./env";
import {
  IDOS_WEB3_NETWORK_ID,
  IDOS_WEB3_WALLETCONNECT_PROJECT_ID,
} from "./idos.title";

// Solana signed-challenge login uses the official lazy SDK component.
// Embedded games delegate wallet connection and signing to the iDosGames platform.
// Standalone mobile WalletConnect requires a publisher-provided Reown project ID.

export const renderWalletLogin: RenderWalletLogin = ({
  client,
  onAuthenticated,
  disabled,
  style,
}) => !isEmbeddedInPlatform() && !(IDOS_WEB3_WALLETCONNECT_PROJECT_ID || ENV_WALLETCONNECT_PROJECT_ID) ? (
  <InjectedSolanaLogin mode="login" client={client} networkID={IDOS_WEB3_NETWORK_ID || "solana"} onAuthenticated={onAuthenticated} disabled={disabled} style={style} />
) : (
  <LazyWalletLogin
    client={client}
    networkID={IDOS_WEB3_NETWORK_ID || "solana"}
    onAuthenticated={onAuthenticated}
    disabled={disabled}
    style={style}
    walletConnectProjectId={
      IDOS_WEB3_WALLETCONNECT_PROJECT_ID ||
      ENV_WALLETCONNECT_PROJECT_ID ||
      undefined
    }
  />
);

// "Link wallet" on the play-access screen (mounted in ./main.tsx) — the same button in link mode. When
// the title's login mode requires a token balance, a player who signed in another way attaches a
// wallet to the account by signature, and the server checks the balance against exactly that
// wallet. `networkID` is the network a requirement needs; the title's own network otherwise.
export const renderWalletLink: RenderLinkWallet = ({
  client,
  networkID,
  onLinked,
  disabled,
  style,
}) => !isEmbeddedInPlatform() && !(IDOS_WEB3_WALLETCONNECT_PROJECT_ID || ENV_WALLETCONNECT_PROJECT_ID) ? (
  <InjectedSolanaLogin mode="link" client={client} networkID={networkID || IDOS_WEB3_NETWORK_ID || "solana"} onLinked={onLinked} disabled={disabled} style={style} />
) : (
  <LazyWalletLogin
    mode="link"
    client={client}
    networkID={networkID || IDOS_WEB3_NETWORK_ID || "solana"}
    onLinked={onLinked}
    disabled={disabled}
    style={style}
    walletConnectProjectId={
      IDOS_WEB3_WALLETCONNECT_PROJECT_ID ||
      ENV_WALLETCONNECT_PROJECT_ID ||
      undefined
    }
  />
);

