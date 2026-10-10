import { useRef, useState } from "react";
import type { RenderLinkWallet, RenderWalletLogin } from "@idosgames/app-shell";
import { linkWalletSolana, loginWithWalletSolana } from "@idosgames/wallet";

type Provider = {
  connect(): Promise<{ publicKey: { toString(): string } }>;
  signMessage(message: Uint8Array, encoding?: string): Promise<Uint8Array | { signature: Uint8Array }>;
};
type Providers = Window & {
  phantom?: { solana?: Provider };
  solflare?: Provider;
  solana?: Provider;
};
type Props = (Parameters<RenderWalletLogin>[0] & { mode: "login"; networkID: string }) |
  (Parameters<RenderLinkWallet>[0] & { mode: "link"; networkID: string });

// Use the SDK's server-issued challenge flow with an injected Solana provider.
// No keys, token approvals, or transactions are requested.
export function InjectedSolanaLogin(props: Props) {
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const pending = useRef(false);
  const signIn = async (wallet: "phantom" | "solflare") => {
    if (pending.current) return;
    const providers = window as Providers;
    const provider = wallet === "phantom" ? providers.phantom?.solana ?? providers.solana : providers.solflare;
    if (!provider?.connect || !provider.signMessage) {
      setError(`Open this page in the ${wallet === "phantom" ? "Phantom" : "Solflare"} browser or install its extension to continue.`);
      return;
    }
    pending.current = true;
    setBusy(true);
    setError(null);
    try {
      const account = await provider.connect();
      const params = {
        client: props.client,
        networkID: props.networkID,
        walletAddress: account.publicKey.toString(),
        signMessage: async (message: Uint8Array) => {
          const signed = await provider.signMessage(message, "utf8");
          return signed instanceof Uint8Array ? signed : signed.signature;
        },
      };
      if (props.mode === "link") {
        const result = await linkWalletSolana(params);
        if (!result.ok) throw new Error(result.error);
        props.onLinked(result.data.PlayAccess ?? null);
      } else {
        const result = await loginWithWalletSolana(params);
        if (!result.ok) throw new Error(result.error);
        props.onAuthenticated();
      }
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : "Wallet sign-in failed. Please try again.");
    } finally {
      pending.current = false;
      setBusy(false);
    }
  };
  return <div style={{ display: "grid", gap: 8, width: "100%" }}>
    <button type="button" style={props.style} disabled={props.disabled || busy} onClick={() => void signIn("phantom")}>{busy ? "Check your wallet…" : "Continue with Phantom"}</button>
    <button type="button" style={props.style} disabled={props.disabled || busy} onClick={() => void signIn("solflare")}>Continue with Solflare</button>
    {error && <span role="alert" style={{ color: "#ff9b9b", fontSize: 13 }}>{error}</span>}
  </div>;
}
