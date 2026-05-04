const STORAGE_KEY = "hepsivar-pwa-state-v2";

const seedState = {
  tasks: [
    { id: "t1", title: "imza", done: false, priority: "Orta", createdAt: Date.now() }
  ],
  shopping: [
    { id: "s1", name: "Süt", qty: 2, bought: false, category: "Süt ürünleri" },
    { id: "s2", name: "Ekmek", qty: 1, bought: false, category: "Fırın" }
  ],
  notes: [
    {
      id: "n1",
      title: "Yayın notu",
      content: "Vercel için hazır PWA. Veriler cihazda kalır, uygulama çevrimdışı açılır.",
      color: "#ffad45",
      updatedAt: Date.now()
    }
  ],
  expenses: [
    { id: "e1", title: "Maaş", amount: 15000, category: "Gelir", date: Date.now(), income: true },
    { id: "e2", title: "Market", amount: 5350, category: "Yiyecek", date: Date.now(), income: false }
  ]
};

const views = {
  tasks: {
    title: "Görevler",
    subtitle: "Öncelikleri ve tamamlananları takip et.",
    accent: "#2d64f4"
  },
  shopping: {
    title: "Liste",
    subtitle: "Alınacakları düzenle, aldıklarını işaretle.",
    accent: "#9867f1"
  },
  notes: {
    title: "Notlar",
    subtitle: "Fikirleri, planları ve kısa notları sakla.",
    accent: "#ffad45"
  },
  expenses: {
    title: "Para",
    subtitle: "Gelir, gider ve bakiyeyi kontrol et.",
    accent: "#45d4a5"
  },
  calendar: {
    title: "Takvim",
    subtitle: "Bu haftaya hızlıca bak.",
    accent: "#2d64f4"
  },
  settings: {
    title: "Ayarlar",
    subtitle: "Verilerini yönet ve PWA deneyimini ayarla.",
    accent: "#64748b"
  }
};

let state = loadState();
let activeView = "tasks";
let taskFilter = "all";
let shoppingFilter = "open";
let expenseMode = "expense";
let deferredPrompt;

const panel = document.querySelector("#panel");
const dashboard = document.querySelector("#dashboard");
const navButtons = [...document.querySelectorAll("[data-view]")];
const installButton = document.querySelector("#installButton");
const searchButton = document.querySelector("#searchButton");
const notifyButton = document.querySelector("#notifyButton");
const searchPanel = document.querySelector("#searchPanel");
const searchInput = document.querySelector("#searchInput");
const searchResults = document.querySelector("#searchResults");

function loadState() {
  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (saved) return JSON.parse(saved);

    const old = localStorage.getItem("hepsivar-pwa-state-v1");
    return old ? normalizeState(JSON.parse(old)) : structuredClone(seedState);
  } catch {
    return structuredClone(seedState);
  }
}

function normalizeState(value) {
  return {
    tasks: Array.isArray(value.tasks) ? value.tasks : [],
    shopping: Array.isArray(value.shopping) ? value.shopping : value.shoppingItems || [],
    notes: Array.isArray(value.notes) ? value.notes : [],
    expenses: Array.isArray(value.expenses) ? value.expenses : []
  };
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
  }).format(value || 0);
}

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function setView(view) {
  activeView = view;
  searchPanel.classList.add("hidden");
  render();
}

function render() {
  const config = views[activeView];
  document.documentElement.style.setProperty("--accent", config.accent);

  navButtons.forEach((button) => {
    button.classList.toggle("active", button.dataset.view === activeView);
  });

  renderDashboard();

  const renderers = {
    tasks: renderTasks,
    shopping: renderShopping,
    notes: renderNotes,
    expenses: renderExpenses,
    calendar: renderCalendar,
    settings: renderSettings
  };

  panel.innerHTML = sectionHead(config.title, config.subtitle, panelStat()) + renderers[activeView]();
  bindPanelEvents();
}

function sectionHead(title, subtitle, stat = "") {
  return `
    <div class="section-head">
      <div>
        <h2>${title}</h2>
        <p>${subtitle}</p>
      </div>
      ${stat ? `<span class="mini-stat">${stat}</span>` : ""}
    </div>
  `;
}

function panelStat() {
  if (activeView === "tasks") return `${state.tasks.filter((task) => !task.done).length} açık`;
  if (activeView === "shopping") return `${state.shopping.filter((item) => !item.bought).length} alınacak`;
  if (activeView === "notes") return `${state.notes.length} not`;
  if (activeView === "expenses") return money(balance());
  return "";
}

function balance() {
  return state.expenses.reduce((sum, item) => sum + (item.income ? item.amount : -item.amount), 0);
}

function renderDashboard() {
  const doneTasks = state.tasks.filter((task) => task.done).length;
  const openShopping = state.shopping.filter((item) => !item.bought).length;

  dashboard.innerHTML = `
    ${metricTemplate("tasks", "blue", "✓", "Tamamlanan", `${doneTasks}/${state.tasks.length || 0}`)}
    ${metricTemplate("shopping", "purple", "▣", "Alınacak", openShopping)}
    ${metricTemplate("notes", "amber", "▤", "Not", state.notes.length)}
    ${metricTemplate("expenses", "green", "₺", "Bakiye", money(balance()))}
  `;
}

function metricTemplate(view, color, icon, label, value) {
  return `
    <button class="metric ${color}" type="button" data-view="${view}" aria-label="${label}">
      <span class="metric-icon">${icon}</span>
      <span class="metric-copy">
        <span>${label}</span>
        <strong>${value}</strong>
      </span>
    </button>
  `;
}

function renderTasks() {
  const visibleTasks = state.tasks.filter((task) => {
    if (taskFilter === "open") return !task.done;
    if (taskFilter === "done") return task.done;
    return true;
  });

  return `
    <form class="composer" data-action="add-task">
      <div class="form-row">
        <input name="title" required autocomplete="off" placeholder="Yeni görev">
        <button class="primary-button" type="submit">Ekle</button>
      </div>
      <select name="priority" aria-label="Öncelik">
        <option>Orta</option>
        <option>Yüksek</option>
        <option>Düşük</option>
      </select>
    </form>
    <div class="filters" role="group" aria-label="Görev filtresi">
      ${filterButton("task-filter", "all", "Hepsi", taskFilter)}
      ${filterButton("task-filter", "open", "Açık", taskFilter)}
      ${filterButton("task-filter", "done", "Biten", taskFilter)}
    </div>
    <div class="list">
      ${visibleTasks.length ? visibleTasks.map(taskTemplate).join("") : emptyState("Görev yok", "Burada gösterecek görev kalmadı.")}
    </div>
  `;
}

function filterButton(action, value, label, current) {
  return `<button class="filter-chip ${value === current ? "active" : ""}" type="button" data-action="${action}" data-value="${value}">${label}</button>`;
}

function taskTemplate(task) {
  return `
    <article class="item ${task.done ? "done" : ""}" data-id="${task.id}">
      <button class="check" type="button" data-action="toggle-task" aria-label="Görevi işaretle">✓</button>
      <div>
        <div class="item-title">${escapeHtml(task.title)}</div>
        <div class="meta">
          <span class="pill">${escapeHtml(task.priority)}</span>
          <span>${new Date(task.createdAt).toLocaleDateString("tr-TR")}</span>
        </div>
      </div>
      <button class="danger-button" type="button" data-action="delete-task" aria-label="Sil">×</button>
    </article>
  `;
}

function renderShopping() {
  const categories = ["Genel", "Süt ürünleri", "Fırın", "Meyve", "Sebze", "Temizlik", "Ev"];
  const visibleItems = state.shopping.filter((item) => {
    if (shoppingFilter === "open") return !item.bought;
    if (shoppingFilter === "done") return item.bought;
    return true;
  });

  return `
    <form class="composer" data-action="add-shopping">
      <div class="form-grid">
        <input name="name" required autocomplete="off" placeholder="Ürün adı">
        <input name="qty" inputmode="numeric" min="1" type="number" value="1" aria-label="Adet">
      </div>
      <div class="form-row">
        <select name="category" aria-label="Kategori">
          ${categories.map((category) => `<option>${category}</option>`).join("")}
        </select>
        <button class="primary-button" type="submit">Ekle</button>
      </div>
    </form>
    <div class="filters" role="group" aria-label="Liste filtresi">
      ${filterButton("shopping-filter", "open", "Alınacak", shoppingFilter)}
      ${filterButton("shopping-filter", "done", "Alındı", shoppingFilter)}
      ${filterButton("shopping-filter", "all", "Hepsi", shoppingFilter)}
    </div>
    <div class="list">
      ${visibleItems.length ? visibleItems.map(shoppingTemplate).join("") : emptyState("Liste boş", "Alışveriş için ürün ekle.")}
    </div>
  `;
}

function shoppingTemplate(item) {
  return `
    <article class="item ${item.bought ? "done" : ""}" data-id="${item.id}">
      <button class="check" type="button" data-action="toggle-shopping" aria-label="Ürünü işaretle">✓</button>
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
      <input name="title" required autocomplete="off" placeholder="Başlık">
      <textarea name="content" required placeholder="Notunu yaz"></textarea>
      <div class="form-row">
        <select name="color" aria-label="Renk">
          <option value="#ffad45">Sarı</option>
          <option value="#2d64f4">Mavi</option>
          <option value="#ff6475">Kırmızı</option>
          <option value="#45d4a5">Yeşil</option>
          <option value="#9867f1">Mor</option>
        </select>
        <button class="primary-button" type="submit">Kaydet</button>
      </div>
    </form>
    <div class="notes-grid">
      ${state.notes.length ? state.notes.map(noteTemplate).join("") : emptyState("Not yok", "Kısa bir not oluştur.")}
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
  const categories = ["Gelir", "Ev", "Yiyecek", "Ulaşım", "Fatura", "Eğlence", "Diğer"];
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
      <div class="toggle" role="group" aria-label="İşlem tipi">
        <button type="button" data-action="set-expense-mode" data-mode="expense" class="${expenseMode === "expense" ? "active" : ""}">Gider</button>
        <button type="button" data-action="set-expense-mode" data-mode="income" class="${expenseMode === "income" ? "active" : ""}">Gelir</button>
      </div>
      <div class="form-grid">
        <input name="title" required autocomplete="off" placeholder="Açıklama">
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
      ${state.expenses.length ? state.expenses.map(expenseTemplate).join("") : emptyState("Kayıt yok", "Gelir veya gider ekle.")}
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

function renderCalendar() {
  const now = new Date();
  const start = new Date(now);
  start.setDate(now.getDate() - ((now.getDay() + 6) % 7));
  const days = Array.from({ length: 7 }, (_, index) => {
    const date = new Date(start);
    date.setDate(start.getDate() + index);
    const isToday = date.toDateString() === now.toDateString();
    return `
      <div class="day ${isToday ? "today" : ""}">
        <span>${date.toLocaleDateString("tr-TR", { weekday: "short" })}</span>
        <strong>${date.getDate()}</strong>
      </div>
    `;
  }).join("");

  return `
    <div class="calendar-grid">
      <article class="calendar-card">
        <h3>Bu hafta</h3>
        <div class="calendar-strip">${days}</div>
      </article>
      <article class="calendar-card">
        <h3>Bugünün odağı</h3>
        <div class="list">
          ${state.tasks.filter((task) => !task.done).slice(0, 3).map(taskTemplate).join("") || emptyState("Plan temiz", "Bugün için açık görev yok.")}
        </div>
      </article>
    </div>
  `;
}

function renderSettings() {
  return `
    <div class="settings-grid">
      <article class="setting-card">
        <h3>Veri özeti</h3>
        <p class="meta">${state.tasks.length} görev · ${state.shopping.length} ürün · ${state.notes.length} not · ${state.expenses.length} para kaydı</p>
        <div class="quick-row">
          <button class="ghost-button" type="button" data-action="export-data">Dışa aktar</button>
          <button class="ghost-button" type="button" data-action="copy-backup">Kopyala</button>
        </div>
      </article>
      <article class="setting-card">
        <h3>PWA</h3>
        <p class="meta">Ana ekrana eklenebilir, çevrimdışı açılır ve Vercel'de statik çalışır.</p>
        <button class="ghost-button" type="button" data-action="install-app">Yüklemeyi dene</button>
      </article>
      <article class="setting-card">
        <h3>Temizlik</h3>
        <p class="meta">Tüm yerel veriyi sıfırla ve örnek veriye dön.</p>
        <button class="danger-button" type="button" data-action="reset-data" aria-label="Sıfırla">×</button>
      </article>
    </div>
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

function handleAction(action, button) {
  const item = button.closest("[data-id]");
  const itemId = item?.dataset.id;

  if (action === "task-filter") taskFilter = button.dataset.value;
  if (action === "shopping-filter") shoppingFilter = button.dataset.value;

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

  if (action === "reset-data" && confirm("Tüm yerel veri sıfırlansın mı?")) {
    state = structuredClone(seedState);
  }

  if (action === "export-data") {
    downloadText("hepsivar-yedek.json", JSON.stringify(state, null, 2));
  }

  if (action === "copy-backup") {
    navigator.clipboard?.writeText(JSON.stringify(state, null, 2));
  }

  if (action === "install-app") {
    promptInstall();
    return;
  }

  saveState();
  render();
}

function downloadText(filename, text) {
  const blob = new Blob([text], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = filename;
  link.click();
  URL.revokeObjectURL(url);
}

function renderSearch(query) {
  const term = query.trim().toLocaleLowerCase("tr-TR");
  if (!term) {
    searchResults.innerHTML = emptyState("Aramaya başla", "Görev, ürün, not veya para kaydı yaz.");
    return;
  }

  const results = [
    ...state.tasks.map((item) => ({ view: "tasks", label: item.title, meta: "Görev" })),
    ...state.shopping.map((item) => ({ view: "shopping", label: item.name, meta: `Liste · ${item.category}` })),
    ...state.notes.map((item) => ({ view: "notes", label: item.title, meta: "Not" })),
    ...state.expenses.map((item) => ({ view: "expenses", label: item.title, meta: `Para · ${money(item.amount)}` }))
  ].filter((item) => `${item.label} ${item.meta}`.toLocaleLowerCase("tr-TR").includes(term));

  searchResults.innerHTML = results.length
    ? results.slice(0, 8).map((item) => `
      <button class="item" type="button" data-view="${item.view}">
        <span class="pill">${item.meta}</span>
        <span class="item-title">${escapeHtml(item.label)}</span>
        <span>›</span>
      </button>
    `).join("")
    : emptyState("Sonuç yok", "Başka bir kelime dene.");
}

function promptInstall() {
  if (!deferredPrompt) return;
  deferredPrompt.prompt();
  deferredPrompt.userChoice.finally(() => {
    deferredPrompt = null;
    installButton.classList.add("hidden");
  });
}

document.addEventListener("click", (event) => {
  const viewButton = event.target.closest("[data-view]");
  if (viewButton) {
    setView(viewButton.dataset.view);
    return;
  }

  const actionButton = event.target.closest("button[data-action]");
  if (actionButton) handleAction(actionButton.dataset.action, actionButton);
});

searchButton.addEventListener("click", () => {
  searchPanel.classList.toggle("hidden");
  if (!searchPanel.classList.contains("hidden")) {
    searchInput.focus();
    renderSearch(searchInput.value);
  }
});

searchInput.addEventListener("input", () => renderSearch(searchInput.value));

notifyButton.addEventListener("click", () => {
  setView("calendar");
});

window.addEventListener("beforeinstallprompt", (event) => {
  event.preventDefault();
  deferredPrompt = event;
  installButton.classList.remove("hidden");
});

installButton.addEventListener("click", promptInstall);

if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("/sw.js");
  });
}

render();
