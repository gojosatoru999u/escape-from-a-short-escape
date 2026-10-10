import type { IDosGamesClient } from "@idosgames/core";
import type { ShopItem } from "./shop";
import { PublicKey } from "@solana/web3.js";

export const BONUS_MINT = "BTfVrZYGHJs8RAMRgfPaioc33WaU8ZweCQbiy5h7idos";
export const BONUS_MIN_RAW = 5_000_000_000n; // 5,000 ESCAPE, 6 decimals.
export const BONUS_RPC = "https://solana-rpc.publicnode.com";
const TOKEN_PROGRAM = "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA";
export function bonusAccount(owner: string): string {
  return PublicKey.findProgramAddressSync([new PublicKey(owner).toBuffer(), new PublicKey(TOKEN_PROGRAM).toBuffer(), new PublicKey(BONUS_MINT).toBuffer()], new PublicKey("ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL"))[0].toBase58();
}

export function tokenBalance(data: unknown, owner: string): bigint {
  const value = (data as { value?: any } | null)?.value;
  if (value === null) return 0n;
  const info = value?.data?.parsed?.info;
  if (value?.owner !== TOKEN_PROGRAM || value?.executable !== false || value?.space !== 165 || value?.data?.parsed?.type !== "account" || info?.mint !== BONUS_MINT || info?.owner !== owner || info?.tokenAmount?.decimals !== 6 || typeof info?.tokenAmount?.amount !== "string" || !/^\d+$/.test(info.tokenAmount.amount))
    throw new Error("Не удалось проверить токен-счёт ESCAPE.");
  const amount = BigInt(info.tokenAmount.amount);
  if (amount > 18_446_744_073_709_551_615n) throw new Error("Некорректный баланс ESCAPE.");
  return amount;
}

export function formatBalance(raw: bigint): string {
  const integer = (raw / 1_000_000n).toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ");
  const fraction = (raw % 1_000_000n).toString().padStart(6, "0").replace(/0+$/, "");
  return integer + (fraction ? "," + fraction : "");
}

export async function readBalance(owner: string, request: typeof fetch = fetch): Promise<bigint> {
  const response = await request(BONUS_RPC, {
    method: "POST", headers: { "Content-Type": "application/json" }, signal: AbortSignal.timeout(12_000),
    body: JSON.stringify({ jsonrpc: "2.0", id: 1, method: "getAccountInfo", params: [bonusAccount(owner), { encoding: "jsonParsed", commitment: "finalized" }] }),
  });
  if (!response.ok) throw new Error("Solana RPC временно недоступен. Попробуйте проверить баланс позже.");
  const body = await response.json();
  if (body.error) throw new Error("Solana не смогла проверить баланс. Попробуйте ещё раз.");
  return tokenBalance(body.result, owner);
}

export function createHolderBonus(client: IDosGamesClient, game: () => { run: number; started: boolean; freeSlots: number }, grant: (item: ShopItem) => void) {
  let run = -1;
  let chosen: ShopItem | undefined;
  let address = "";
  let busy = false;
  function current() { const state = game(); if (run !== state.run) { run = state.run; chosen = undefined; } return state; }
  async function wallets() {
    const result = await client.blockchain.getPlayAccess();
    if (!result.ok) throw new Error("Не удалось загрузить кошельки аккаунта. Повторите проверку.");
    return [...new Set((result.data.LinkedWallets ?? []).filter(w => w.NetworkID === "solana").map(w => w.Address ?? "").filter(Boolean))];
  }
  return {
    async check(selected?: string) {
      current();
      const addresses = await wallets();
      address = selected && addresses.includes(selected) ? selected : addresses.includes(address) ? address : addresses[0] ?? "";
      const balance = address ? await readBalance(address) : null;
      return { addresses, address, balance, chosen, eligible: balance !== null && balance >= BONUS_MIN_RAW && !chosen };
    },
    async link() {
      const sdk = await import("@idosgames/wallet");
      if (sdk.isEmbeddedInPlatform()) {
        const result = await sdk.linkWalletViaPlatform({ client, networkID: "solana", family: "solana" });
        if (!result.ok) throw new Error(result.error);
      } else {
        type Provider = { connect(): Promise<{ publicKey: { toString(): string } }>; signMessage(m: Uint8Array, encoding?: string): Promise<Uint8Array | { signature: Uint8Array }> };
        const w = window as Window & { phantom?: { solana?: Provider }; solflare?: Provider; solana?: Provider };
        const provider = w.phantom?.solana ?? w.solflare ?? w.solana;
        if (!provider?.signMessage) throw new Error("Откройте игру в Chrome с Phantom/Solflare или в браузере кошелька.");
        const account = await provider.connect();
        const result = await sdk.linkWalletSolana({ client, networkID: "solana", walletAddress: account.publicKey.toString(), signMessage: async message => { const signed = await provider.signMessage(message, "utf8"); return signed instanceof Uint8Array ? signed : signed.signature; } });
        if (!result.ok) throw new Error(result.error);
      }
    },
    async claim(item: ShopItem) {
      if (busy) throw new Error("Проверка уже идёт.");
      busy = true;
      try {
        const start = current(); const startRun = run;
        if (chosen) throw new Error("Бонус в этом прохождении уже выбран.");
        if (!["Pickaxe", "Club", "Sword"].includes(item)) throw new Error("Неизвестный инструмент.");
        if (!start.started || start.freeSlots < 1) throw new Error("Освободите место в инвентаре и завершите вступление.");
        const state = await this.check(address);
        if (!state.eligible) throw new Error("Для бонуса держите минимум 5 000 ESCAPE в выбранном кошельке.");
        const latest = current();
        if (startRun !== run || !latest.started || latest.freeSlots < 1 || chosen) throw new Error("Состояние игры изменилось. Повторите выбор.");
        chosen = item; grant(item);
      } finally { busy = false; }
    },
  };
}
export type HolderBonus = ReturnType<typeof createHolderBonus>;
