const STORAGE_KEY = "hepsivar-pwa-state-v1";

const seedState = {
  tasks: [
    { id: "t1", title: "Mobil PWA'yi tamamla", done: true, priority: "Yuksek", createdAt: Date.now() },
    { id: "t2", title: "Vercel deploy hazirligini kontrol et", done: false, priority: "Orta", createdAt: Date.now() }
  ],
  shopping: [
    { id: "s1", name: "Sut", qty: 2, bought: false, category: "Sut urunleri" },
    { id: "s2", name: "Ekmek", qty: 1, bought: false, category: "Firin" },
    { id: "s3", name: "Elma", qty: 5, bought: true, category: "Meyve" }
  ],
  notes: [
    {
      id: "n1",
      title: "Yayin notu",
      content: "Bu PWA verileri cihazda saklar ve cevrimdisi acilir.",
      color: "#d97706",
      updatedAt: Date.now()
    }
  ],
  expenses: [
    { id: "e1", title: "Maas", amount: 15000, category: "Gelir", date: Date.now(), income: true },
    { id: "e2", title: "Kira", amount: 4500, category: "Ev", date: Date.now(), income: false },
    { id: "e3", title: "Market", amount: 850, category: "Yiyecek", date: Date.now(), income: false }
  ]
};

const views = {
  tasks: {
    title: "Gorevler",
    subtitle: "Oncelikleri ve tamamlananlari takip et.",
    accent: "#2563eb"
  },
  shopping: {
    title: "Alisveris",
    subtitle: "Listeyi hazirla, aldiklarini isaretle.",
    accent: "#e11d48"
  },
  notes: {
    title: "Notlar",
    subtitle: "Fikirleri ve kisa notlari sakla.",
    accent: "#d97706"
  },
  expenses: {
    title: "Harcamalar",
    subtitle: "Gelir, gider ve bakiye kontrolu.",
    accent: "#059669"
  }
};

let state = loadState();
let activeView = "tasks";
let expenseMode = "expense";

const panel = document.querySelector("#panel");
const dashboard = document.querySelector("#dashboard");
const tabs = [...document.querySelectorAll(".tab")];
const installButton = document.querySelector("#installButton");

function loadState() {
  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    return saved ? JSON.parse(saved) : structuredClone(seedState);
  } catch {
    return structuredClone(seedState);
  }
}

function saveState() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

function id(prefix) {
  return `${prefix}${Date.now().toString(36)}${Math.random().toString(36).slice(2, 7)}`;
}

function money(value) {
  return new Intl.NumberFormat("tr-TR", {
    style: "currency",
    currency: "TRY",
    maximumFractionDigits: 0
  }).format(value);
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function render() {
  const config = views[activeView];
  document.documentElement.style.setProperty("--accent", config.accent);
  tabs.forEach((tab) => tab.classList.toggle("active", tab.dataset.view === activeView));
  renderDashboard();

  const renderers = {
    tasks: renderTasks,
    shopping: renderShopping,
    notes: renderNotes,
    expenses: renderExpenses
  };

  panel.innerHTML = sectionHead(config.title, config.subtitle) + renderers[activeView]();
  bindPanelEvents();
}

function sectionHead(title, subtitle) {
  return `
    <div class="section-head">
      <div>
        <h2>${title}</h2>
        <p>${subtitle}</p>
      </div>
    </div>
  `;
}

function renderDashboard() {
  const doneTasks = state.tasks.filter((task) => task.done).length;
  const openShopping = state.shopping.filter((item) => !item.bought).length;
  const income = state.expenses.filter((item) => item.income).reduce((sum, item) => sum + item.amount, 0);
  const expense = state.expenses.filter((item) => !item.income).reduce((sum, item) => sum + item.amount, 0);

  dashboard.innerHTML = `
    <article class="metric blue"><span>Tamamlanan</span><strong>${doneTasks}/${state.tasks.length}</strong></article>
    <article class="metric rose"><span>Alinacak</span><strong>${openShopping}</strong></article>
    <article class="metric amber"><span>Not</span><strong>${state.notes.length}</strong></article>
    <article class="metric green"><span>Bakiye</span><strong>${money(income - expense)}</strong></article>
  `;
}

function renderTasks() {
  return `
    <form class="composer" data-action="add-task">
      <div class="form-row">
        <input name="title" required autocomplete="off" placeholder="Yeni gorev">
        <button class="primary-button" type="submit">Ekle</button>
      </div>
      <select name="priority" aria-label="Oncelik">
        <option>Orta</option>
        <option>Yuksek</option>
        <option>Dusuk</option>
      </select>
    </form>
    <div class="list">
      ${state.tasks.length ? state.tasks.map(taskTemplate).join("") : emptyState("Gorev yok", "Ilk gorevini ekle.")}
    </div>
  `;
}

function taskTemplate(task) {
  return `
    <article class="item ${task.done ? "done" : ""}" data-id="${task.id}">
      <button class="check" type="button" data-action="toggle-task" aria-label="Gorevi isaretle">✓</button>
      <div>
        <div class="item-title">${escapeHtml(task.title)}</div>
        <div class="meta"><span class="pill">${escapeHtml(task.priority)}</span></div>
      </div>
      <button class="danger-button" type="button" data-action="delete-task" aria-label="Sil">×</button>
    </article>
  `;
}

function renderShopping() {
  const categories = ["Genel", "Sut urunleri", "Firin", "Meyve", "Sebze", "Temizlik", "Ev"];
  return `
    <form class="composer" data-action="add-shopping">
      <div class="form-grid">
        <input name="name" required autocomplete="off" placeholder="Urun adi">
        <input name="qty" inputmode="numeric" min="1" type="number" value="1" aria-label="Adet">
      </div>
      <div class="form-row">
        <select name="category" aria-label="Kategori">
          ${categories.map((category) => `<option>${category}</option>`).join("")}
        </select>
        <button class="primary-button" type="submit">Ekle</button>
      </div>
    </form>
    <div class="list">
      ${state.shopping.length ? state.shopping.map(shoppingTemplate).join("") : emptyState("Liste bos", "Alisveris icin urun ekle.")}
    </div>
  `;
}

function shoppingTemplate(item) {
  return `
    <article class="item ${item.bought ? "done" : ""}" data-id="${item.id}">
      <button class="check" type="button" data-action="toggle-shopping" aria-label="Urunu isaretle">✓</button>
      <div>
        <div class="item-title">${escapeHtml(item.name)}</div>
        <div class="meta">
          <span class="pill">${escapeHtml(item.category)}</span>
          <span>${item.qty} adet</span>
        </div>
      </div>
      <button class="danger-button" type="button" data-action="delete-shopping" aria-label="Sil">×</button>
    </article>
  `;
}

function renderNotes() {
  return `
    <form class="composer" data-action="add-note">
      <input name="title" required autocomplete="off" placeholder="Baslik">
      <textarea name="content" required placeholder="Notunu yaz"></textarea>
      <div class="form-row">
        <select name="color" aria-label="Renk">
          <option value="#d97706">Sari</option>
          <option value="#2563eb">Mavi</option>
          <option value="#e11d48">Kirmizi</option>
          <option value="#059669">Yesil</option>
        </select>
        <button class="primary-button" type="submit">Kaydet</button>
      </div>
    </form>
    <div class="notes-grid">
      ${state.notes.length ? state.notes.map(noteTemplate).join("") : emptyState("Not yok", "Kisa bir not olustur.")}
    </div>
  `;
}

function noteTemplate(note) {
  return `
    <article class="note-card" style="--note-color:${note.color}" data-id="${note.id}">
      <h3>${escapeHtml(note.title)}</h3>
      <p>${escapeHtml(note.content)}</p>
      <div class="meta">${new Date(note.updatedAt).toLocaleDateString("tr-TR")}</div>
      <div class="note-actions">
        <button class="danger-button" type="button" data-action="delete-note" aria-label="Sil">×</button>
      </div>
    </article>
  `;
}

function renderExpenses() {
  const categories = ["Gelir", "Ev", "Yiyecek", "Ulasim", "Fatura", "Eglence", "Diger"];
  const income = state.expenses.filter((item) => item.income).reduce((sum, item) => sum + item.amount, 0);
  const expense = state.expenses.filter((item) => !item.income).reduce((sum, item) => sum + item.amount, 0);

  return `
    <article class="summary-card item">
      <div class="pill">Toplam</div>
      <div>
        <div class="item-title">${money(income - expense)}</div>
        <div class="meta">Gelir ${money(income)} · Gider ${money(expense)}</div>
      </div>
      <span></span>
    </article>
    <form class="composer" data-action="add-expense">
      <div class="toggle" role="group" aria-label="Islem tipi">
        <button type="button" data-action="set-expense-mode" data-mode="expense" class="${expenseMode === "expense" ? "active" : ""}">Gider</button>
        <button type="button" data-action="set-expense-mode" data-mode="income" class="${expenseMode === "income" ? "active" : ""}">Gelir</button>
      </div>
      <div class="form-grid">
        <input name="title" required autocomplete="off" placeholder="Aciklama">
        <input name="amount" required inputmode="decimal" type="number" min="0" step="0.01" placeholder="Tutar">
      </div>
      <div class="form-row">
        <select name="category" aria-label="Kategori">
          ${categories.map((category) => `<option>${category}</option>`).join("")}
        </select>
        <button class="primary-button" type="submit">Ekle</button>
      </div>
    </form>
    <div class="list">
      ${state.expenses.length ? state.expenses.map(expenseTemplate).join("") : emptyState("Kayit yok", "Gelir veya gider ekle.")}
    </div>
  `;
}

function expenseTemplate(item) {
  return `
    <article class="item money-item" data-id="${item.id}">
      <span class="pill">${escapeHtml(item.category)}</span>
      <div>
        <div class="item-title">${escapeHtml(item.title)}</div>
        <div class="meta">${new Date(item.date).toLocaleDateString("tr-TR")}</div>
      </div>
      <div class="amount ${item.income ? "income" : "expense"}">
        ${item.income ? "+" : "-"}${money(item.amount)}
      </div>
      <button class="danger-button" type="button" data-action="delete-expense" aria-label="Sil">×</button>
    </article>
  `;
}

function emptyState(title, text) {
  return `
    <div class="empty-state">
      <strong>${title}</strong>
      <p>${text}</p>
    </div>
  `;
}

function bindPanelEvents() {
  panel.querySelectorAll("form").forEach((form) => {
    form.addEventListener("submit", (event) => {
      event.preventDefault();
      const data = new FormData(form);
      const action = form.dataset.action;

      if (action === "add-task") {
        state.tasks.unshift({
          id: id("t"),
          title: data.get("title").trim(),
          done: false,
          priority: data.get("priority"),
          createdAt: Date.now()
        });
      }

      if (action === "add-shopping") {
        state.shopping.unshift({
          id: id("s"),
          name: data.get("name").trim(),
          qty: Number(data.get("qty")) || 1,
          bought: false,
          category: data.get("category")
        });
      }

      if (action === "add-note") {
        state.notes.unshift({
          id: id("n"),
          title: data.get("title").trim(),
          content: data.get("content").trim(),
          color: data.get("color"),
          updatedAt: Date.now()
        });
      }

      if (action === "add-expense") {
        state.expenses.unshift({
          id: id("e"),
          title: data.get("title").trim(),
          amount: Number(data.get("amount")) || 0,
          category: data.get("category"),
          date: Date.now(),
          income: expenseMode === "income"
        });
      }

      saveState();
      render();
    });
  });
}

panel.addEventListener("click", (event) => {
  const button = event.target.closest("button[data-action]");
  if (!button) return;

  const item = button.closest("[data-id]");
  const action = button.dataset.action;
  const itemId = item?.dataset.id;

  if (action === "set-expense-mode") {
    expenseMode = button.dataset.mode;
    render();
    return;
  }

  if (action === "toggle-task") {
    const task = state.tasks.find((entry) => entry.id === itemId);
    if (task) task.done = !task.done;
  }

  if (action === "delete-task") state.tasks = state.tasks.filter((entry) => entry.id !== itemId);

  if (action === "toggle-shopping") {
    const shoppingItem = state.shopping.find((entry) => entry.id === itemId);
    if (shoppingItem) shoppingItem.bought = !shoppingItem.bought;
  }

  if (action === "delete-shopping") state.shopping = state.shopping.filter((entry) => entry.id !== itemId);
  if (action === "delete-note") state.notes = state.notes.filter((entry) => entry.id !== itemId);
  if (action === "delete-expense") state.expenses = state.expenses.filter((entry) => entry.id !== itemId);

  saveState();
  render();
});

tabs.forEach((tab) => {
  tab.addEventListener("click", () => {
    activeView = tab.dataset.view;
    render();
  });
});

let deferredPrompt;
window.addEventListener("beforeinstallprompt", (event) => {
  event.preventDefault();
  deferredPrompt = event;
  installButton.classList.remove("hidden");
});

installButton.addEventListener("click", async () => {
  if (!deferredPrompt) return;
  deferredPrompt.prompt();
  await deferredPrompt.userChoice;
  deferredPrompt = null;
  installButton.classList.add("hidden");
});

if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("/sw.js");
  });
}

render();
