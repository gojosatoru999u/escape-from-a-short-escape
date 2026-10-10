import { defineModule, type EngineScene } from "@idosgames/module-sdk";
import { createShop, type ShopItem } from "./shop";
import { createHolderBonus } from "./holderBonus";

type GodotEngine = {
  startGame(options: Record<string, unknown>): Promise<void>;
  requestQuit(): void;
};
type GameWindow = Window & {
  Engine?: new (options: Record<string, unknown>) => GodotEngine;
  escapeGameActive?: boolean;
  escapeGameState?: Record<string, unknown>;
  escapeOpenShop?: () => void;
  escapeShopOwned?: ShopItem[];
};
const gameWindow = window as GameWindow;
let loader: Promise<void> | undefined;
function loadEngine(): Promise<void> {
  if (gameWindow.Engine) return Promise.resolve();
  return loader ??= new Promise((resolve, reject) => {
    const script = document.createElement("script");
    script.src = new URL("game/index.js", document.baseURI).href;
    script.onload = () => resolve();
    script.onerror = () => { loader = undefined; script.remove(); reject(new Error("Could not load Godot. Reload to retry.")); };
    document.head.append(script);
  });
}

export const escapeIslandModule = defineModule({
  id: "escape-island",
  meta: { name: "Escape From A Short Escape", type: "game", genre: "survival", engine: "dom" },
  setup(ctx) {
    let canvas: HTMLCanvasElement | undefined;
    let engine: GodotEngine | undefined;
    let ready = Promise.resolve();
    let destroyed = false;
    let generation = 0;
    let active = false;
    let shopOpen = false;
    const syncRunning = () => { gameWindow.escapeGameActive = active && !destroyed && !shopOpen; };
    const bonus = createHolderBonus(ctx.client, () => ({
      run: generation * 1_000_000 + Number(gameWindow.escapeGameState?.run ?? 0),
      started: gameWindow.escapeGameState?.started === true,
      freeSlots: Number(gameWindow.escapeGameState?.freeSlots ?? 0),
    }), item => { if (!destroyed) gameWindow.escapeShopOwned = [item]; });
    const shop = createShop(bonus, open => { shopOpen = open; syncRunning(); });
    const scene: EngineScene = {
      surface: "fullbleed-canvas",
      mount({ host }) {
        const mountGeneration = ++generation;
        destroyed = false;
        active = false;
        syncRunning();
        gameWindow.escapeOpenShop = () => { void shop.open(); };
        gameWindow.escapeShopOwned = [];
        canvas = document.createElement("canvas");
        canvas.id = "escape-godot-canvas";
        canvas.tabIndex = 0;
        canvas.setAttribute("aria-label", "Island survival game. WASD or arrows: move; E: interact; Tab: inventory; Space: attack.");
        canvas.style.cssText = "width:100%;height:100%;display:block;";
        host.append(canvas);
        const target = canvas;
        ready = (async () => {
          await loadEngine();
          if (destroyed || generation !== mountGeneration) return;
          if (!gameWindow.Engine) throw new Error("Godot engine is unavailable. Reload to retry.");
          const executable = new URL("game/index", document.baseURI).href;
          const instance = new gameWindow.Engine({ canvas: target, executable, mainPack: `${executable}.pck`, canvasResizePolicy: 2, focusCanvas: true, experimentalVK: false });
          engine = instance;
          await instance.startGame({ executable, mainPack: `${executable}.pck` });
          if (destroyed || generation !== mountGeneration) { instance.requestQuit(); return; }
          target.focus();
        })();
      },
      ready: () => ready,
      activate() { active = true; syncRunning(); canvas?.focus(); },
      suspend() { active = false; syncRunning(); },
      destroy() {
        ++generation;
        destroyed = true;
        active = false;
        gameWindow.escapeGameActive = false;
        shop.destroy();
        delete gameWindow.escapeOpenShop;
        delete gameWindow.escapeShopOwned;
        engine?.requestQuit();
        engine = undefined;
        canvas?.remove();
        canvas = undefined;
        delete gameWindow.escapeGameState;
      },
      // Godot's WebGL drawing buffer is not preserved; do not return a black frame.
      capture: async () => null,
    };
    ctx.registerScene(scene);
    ctx.registerRoute({ id: "escape-island", label: "Escape From A Short Escape", icon: "🏝️" });
    ctx.exposeToAgent({
      state: () => ({ mounted: !!canvas, playing: gameWindow.escapeGameActive === true, shopOpen, game: gameWindow.escapeGameState ?? null }),
      actions: { focus: () => { canvas?.focus(); return { focused: document.activeElement === canvas }; } },
      describeActions: { focus: "Focus the game canvas for keyboard input." },
    });
  },
});
