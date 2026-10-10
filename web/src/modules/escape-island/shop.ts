import './shop.css';
import { formatBalance, type HolderBonus } from './holderBonus';

export const SHOP_ITEMS = [
  { id: 'Pickaxe', name: 'Кирка', image: 'pickaxe', description: 'Добывайте камни и кристаллы.' },
  { id: 'Club', name: 'Дубина', image: 'club', description: 'Защищайтесь от врагов.' },
  { id: 'Sword', name: 'Меч', image: 'sword', description: 'Исследуйте остров с оружием.' },
] as const;
export type ShopItem = typeof SHOP_ITEMS[number]['id'];

export function createShop(bonus: HolderBonus, onOpenChange: (open: boolean) => void) {
  let dialog: HTMLDialogElement | undefined;
  let busy = false;
  let previousFocus: HTMLElement | null = null;
  function close() {
    if (busy) return;
    dialog?.close(); dialog?.remove(); dialog = undefined;
    onOpenChange(false); previousFocus?.focus();
  }
  async function open() {
    if (dialog) return;
    previousFocus = document.activeElement instanceof HTMLElement ? document.activeElement : null;
    const current = document.createElement('dialog'); dialog = current;
    current.className = 'escape-shop'; current.setAttribute('aria-labelledby', 'escape-shop-title');
    current.innerHTML = `<header><img src="${new URL('shop/shop-icon.png', document.baseURI)}" alt=""/><div><small>БОНУС ДЛЯ ХОЛДЕРОВ</small><h1 id="escape-shop-title">Ваш инструмент для побега</h1></div><button class="shop-close" aria-label="Закрыть бонусы">×</button></header><p class="shop-intro">Держите минимум <strong>5 000 ESCAPE</strong> и получите один инструмент на выбор за прохождение. Токены остаются в вашем кошельке.</p><div class="bonus-controls"><label>Кошелёк <select aria-label="Кошелёк для проверки"></select></label><button class="bonus-link">Подтвердить кошелёк</button><button class="bonus-check">Проверить баланс</button></div><p class="bonus-balance"></p><div class="shop-items"></div><p class="shop-status" role="status" aria-live="polite">Загружаем кошельки…</p><footer>Игра бесплатна. Все инструменты также можно создать из ресурсов.<br/>Один бонус за прохождение; при новой игре баланс проверяется заново. Уже полученный предмет сохраняется до конца прохождения.</footer>`;
    const status = current.querySelector<HTMLElement>('.shop-status')!;
    const balance = current.querySelector<HTMLElement>('.bonus-balance')!;
    const select = current.querySelector<HTMLSelectElement>('select')!;
    const link = current.querySelector<HTMLButtonElement>('.bonus-link')!;
    const check = current.querySelector<HTMLButtonElement>('.bonus-check')!;
    const closeButton = current.querySelector<HTMLButtonElement>('.shop-close')!;
    const cards = current.querySelector<HTMLElement>('.shop-items')!;
    const buttons: HTMLButtonElement[] = [];
    let state: Awaited<ReturnType<HolderBonus['check']>> | undefined;
    function render() {
      if (dialog !== current) return;
      buttons.forEach((b, i) => { b.disabled = busy || !state?.eligible; b.textContent = state?.chosen === SHOP_ITEMS[i]!.id ? 'Получено' : state?.chosen ? 'Бонус уже выбран' : 'Выбрать бесплатно'; });
      check.disabled = busy; link.disabled = busy; select.disabled = busy; closeButton.disabled = busy;
    }
    async function refresh() {
      state = undefined; render();
      try {
        const next = await bonus.check(select.value);
        if (dialog !== current) return;
        state = next; select.replaceChildren();
        for (const address of next.addresses) { const option = document.createElement('option'); option.value = address; option.textContent = address.slice(0,6)+'…'+address.slice(-6); select.append(option); }
        select.value = next.address;
        balance.textContent = next.balance !== null ? `Основной токен-счёт: ${formatBalance(next.balance)} ESCAPE` : 'Нет подтверждённого Solana-кошелька.';
        status.textContent = next.chosen ? 'Бонус уже получен в этом прохождении.' : next.eligible ? 'Бонус доступен. Выберите один инструмент.' : next.address ? 'Для бонуса нужно минимум 5 000 ESCAPE. После покупки токена проверьте баланс снова.' : 'Подтвердите кошелёк подписью сообщения. Это не платёж.';
      } catch (error) { if (dialog === current) { balance.textContent = ''; status.textContent = error instanceof Error ? error.message : 'Баланс проверить не удалось. Попробуйте ещё раз.'; } }
      render();
    }
    async function action(fn: () => Promise<void>) {
      if (busy) return; busy = true; render(); status.textContent = 'Проверяем…';
      try { await fn(); }
      catch (error) { status.textContent = error instanceof Error ? error.message : 'Действие не завершено. Попробуйте ещё раз.'; }
      finally { busy = false; render(); }
    }
    for (const item of SHOP_ITEMS) {
      const card = document.createElement('article');
      card.innerHTML = `<img class="tool-sprite" src="${new URL(`shop/${item.image}.png`, document.baseURI)}" alt=""/><h2>${item.name}</h2><p>${item.description}</p><span class="shop-price">Бесплатно</span><button disabled>Выбрать бесплатно</button>`;
      const button = card.querySelector('button')!; buttons.push(button);
      button.onclick = () => void action(async () => { await bonus.claim(item.id); await refresh(); }); cards.append(card);
    }
    check.onclick = () => void action(refresh);
    select.onchange = () => void action(refresh);
    link.onclick = () => void action(async () => { await bonus.link(); await refresh(); });
    closeButton.onclick = close;
    current.addEventListener('keydown', event => event.stopPropagation());
    current.addEventListener('cancel', event => { event.preventDefault(); close(); });
    document.body.append(current); current.showModal(); onOpenChange(true);
    await action(refresh);
  }
  return { open, close, destroy() { dialog?.remove(); dialog = undefined; busy = false; onOpenChange(false); }, isOpen: () => !!dialog };
}
