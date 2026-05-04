import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HepsiVar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Nunito',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ─── Models ───────────────────────────────────────────────
class Task {
  String id;
  String title;
  bool isDone;
  String priority; // low, medium, high
  DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.isDone = false,
    this.priority = 'medium',
    required this.createdAt,
  });
}

class ShoppingItem {
  String id;
  String name;
  int quantity;
  bool isBought;
  String category;

  ShoppingItem({
    required this.id,
    required this.name,
    this.quantity = 1,
    this.isBought = false,
    this.category = 'Genel',
  });
}

class Note {
  String id;
  String title;
  String content;
  Color color;
  DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.updatedAt,
  });
}

class Expense {
  String id;
  String title;
  double amount;
  String category;
  DateTime date;
  bool isIncome;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.isIncome = false,
  });
}

// ─── App State ────────────────────────────────────────────
class AppState extends ChangeNotifier {
  List<Task> tasks = [
    Task(id: '1', title: 'Flutter uygulaması yap', isDone: true, priority: 'high', createdAt: DateTime.now()),
    Task(id: '2', title: 'Backend bağlantısını kur', isDone: false, priority: 'high', createdAt: DateTime.now()),
    Task(id: '3', title: 'Vercel\'e deploy et', isDone: false, priority: 'medium', createdAt: DateTime.now()),
  ];

  List<ShoppingItem> shoppingItems = [
    ShoppingItem(id: '1', name: 'Süt', quantity: 2, category: 'Süt Ürünleri'),
    ShoppingItem(id: '2', name: 'Ekmek', quantity: 1, category: 'Fırın'),
    ShoppingItem(id: '3', name: 'Elma', quantity: 5, category: 'Meyve'),
  ];

  List<Note> notes = [
    Note(
      id: '1',
      title: 'Fikirler 💡',
      content: 'Backend için ChatGPT API kullan\nVeritabanı: Firebase veya Supabase\nVercel üzerinde yayınla',
      color: const Color(0xFFFFF176),
      updatedAt: DateTime.now(),
    ),
    Note(
      id: '2',
      title: 'Alışveriş Notları 🛒',
      content: 'Hafta sonu alışverişi yapmayı unutma!',
      color: const Color(0xFFB2EBF2),
      updatedAt: DateTime.now(),
    ),
  ];

  List<Expense> expenses = [
    Expense(id: '1', title: 'Maaş', amount: 15000, category: 'Gelir', date: DateTime.now(), isIncome: true),
    Expense(id: '2', title: 'Kira', amount: 4500, category: 'Ev', date: DateTime.now(), isIncome: false),
    Expense(id: '3', title: 'Market', amount: 850, category: 'Yiyecek', date: DateTime.now(), isIncome: false),
    Expense(id: '4', title: 'Ulaşım', amount: 300, category: 'Ulaşım', date: DateTime.now(), isIncome: false),
  ];

  // Tasks
  void addTask(Task t) { tasks.add(t); notifyListeners(); }
  void toggleTask(String id) {
    final i = tasks.indexWhere((t) => t.id == id);
    if (i != -1) { tasks[i].isDone = !tasks[i].isDone; notifyListeners(); }
  }
  void deleteTask(String id) { tasks.removeWhere((t) => t.id == id); notifyListeners(); }

  // Shopping
  void addShoppingItem(ShoppingItem item) { shoppingItems.add(item); notifyListeners(); }
  void toggleShoppingItem(String id) {
    final i = shoppingItems.indexWhere((s) => s.id == id);
    if (i != -1) { shoppingItems[i].isBought = !shoppingItems[i].isBought; notifyListeners(); }
  }
  void deleteShoppingItem(String id) { shoppingItems.removeWhere((s) => s.id == id); notifyListeners(); }

  // Notes
  void addNote(Note n) { notes.add(n); notifyListeners(); }
  void updateNote(Note n) {
    final i = notes.indexWhere((note) => note.id == n.id);
    if (i != -1) { notes[i] = n; notifyListeners(); }
  }
  void deleteNote(String id) { notes.removeWhere((n) => n.id == id); notifyListeners(); }

  // Expenses
  void addExpense(Expense e) { expenses.add(e); notifyListeners(); }
  void deleteExpense(String id) { expenses.removeWhere((e) => e.id == id); notifyListeners(); }

  double get totalIncome => expenses.where((e) => e.isIncome).fold(0, (s, e) => s + e.amount);
  double get totalExpense => expenses.where((e) => !e.isIncome).fold(0, (s, e) => s + e.amount);
  double get balance => totalIncome - totalExpense;
}

// ─── Home Screen ──────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final AppState _state = AppState();

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      TasksScreen(state: _state),
      ShoppingScreen(state: _state),
      NotesScreen(state: _state),
      ExpenseScreen(state: _state),
    ];

    final navItems = [
      {'icon': Icons.check_circle_outline_rounded, 'label': 'Görevler', 'color': const Color(0xFF6C63FF)},
      {'icon': Icons.shopping_cart_outlined, 'label': 'Alışveriş', 'color': const Color(0xFFFF6584)},
      {'icon': Icons.sticky_note_2_outlined, 'label': 'Notlar', 'color': const Color(0xFFFFB300)},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Harcama', 'color': const Color(0xFF43D17A)},
    ];

    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFFFF6584),
      const Color(0xFFFFB300),
      const Color(0xFF43D17A),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: colors[_currentIndex].withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (i) {
                final isSelected = _currentIndex == i;
                final item = navItems[i];
                return GestureDetector(
                  onTap: () => setState(() => _currentIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 20 : 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (item['color'] as Color).withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          color: isSelected
                              ? item['color'] as Color
                              : Colors.grey.shade400,
                          size: 22,
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Text(
                            item['label'] as String,
                            style: TextStyle(
                              color: item['color'] as Color,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Tasks Screen ─────────────────────────────────────────
class TasksScreen extends StatefulWidget {
  final AppState state;
  const TasksScreen({super.key, required this.state});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _controller = TextEditingController();
  String _selectedPriority = 'medium';

  Map<String, dynamic> _priorityData(String p) {
    switch (p) {
      case 'high': return {'label': 'Yüksek', 'color': const Color(0xFFFF5252), 'icon': Icons.local_fire_department_rounded};
      case 'low': return {'label': 'Düşük', 'color': const Color(0xFF43D17A), 'icon': Icons.arrow_downward_rounded};
      default: return {'label': 'Orta', 'color': const Color(0xFFFFB300), 'icon': Icons.remove_rounded};
    }
  }

  void _addTask() {
    if (_controller.text.trim().isEmpty) return;
    widget.state.addTask(Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _controller.text.trim(),
      priority: _selectedPriority,
      createdAt: DateTime.now(),
    ));
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tasks = widget.state.tasks;
    final done = tasks.where((t) => t.isDone).length;
    final total = tasks.length;
    final progress = total == 0 ? 0.0 : done / total;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF6C63FF),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF9C8FFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('✅ Görevlerim', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text('$done / $total tamamlandı', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Yeni görev ekle...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onSubmitted: (_) { _addTask(); setState(() {}); },
                    ),
                  ),
                  const SizedBox(width: 8),
                  _PriorityPicker(
                    selected: _selectedPriority,
                    onChanged: (v) => setState(() => _selectedPriority = v),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () { _addTask(); setState(() {}); },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final task = tasks[i];
                final pd = _priorityData(task.priority);
                return Dismissible(
                  key: Key(task.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_rounded, color: Colors.white),
                  ),
                  onDismissed: (_) { widget.state.deleteTask(task.id); setState(() {}); },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: GestureDetector(
                        onTap: () { widget.state.toggleTask(task.id); setState(() {}); },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: task.isDone ? const Color(0xFF6C63FF) : Colors.transparent,
                            border: Border.all(color: task.isDone ? const Color(0xFF6C63FF) : Colors.grey.shade300, width: 2),
                            shape: BoxShape.circle,
                          ),
                          child: task.isDone ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
                        ),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isDone ? TextDecoration.lineThrough : null,
                          color: task.isDone ? Colors.grey : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (pd['color'] as Color).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(pd['icon'] as IconData, color: pd['color'] as Color, size: 16),
                      ),
                    ),
                  ),
                );
              },
              childCount: tasks.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

class _PriorityPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _PriorityPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = {'high': const Color(0xFFFF5252), 'medium': const Color(0xFFFFB300), 'low': const Color(0xFF43D17A)};
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          builder: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: ['high', 'medium', 'low'].map((p) => ListTile(
              leading: CircleAvatar(backgroundColor: colors[p], radius: 8),
              title: Text(p == 'high' ? 'Yüksek' : p == 'medium' ? 'Orta' : 'Düşük'),
              onTap: () { onChanged(p); Navigator.pop(context); },
            )).toList(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: (colors[selected]!).withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.flag_rounded, color: colors[selected], size: 20),
      ),
    );
  }
}

// ─── Shopping Screen ──────────────────────────────────────
class ShoppingScreen extends StatefulWidget {
  final AppState state;
  const ShoppingScreen({super.key, required this.state});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final _nameCtrl = TextEditingController();
  int _qty = 1;

  void _add() {
    if (_nameCtrl.text.trim().isEmpty) return;
    widget.state.addShoppingItem(ShoppingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      quantity: _qty,
    ));
    _nameCtrl.clear();
    _qty = 1;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.state.shoppingItems;
    final bought = items.where((i) => i.isBought).length;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F3),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: const Color(0xFFFF6584),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6584), Color(0xFFFF9AAE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('🛒 Alışveriş', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                      Text('$bought / ${items.length} sepete alındı', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        hintText: 'Ürün adı...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onSubmitted: (_) { _add(); },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        IconButton(icon: const Icon(Icons.remove_rounded, size: 18), onPressed: () { if (_qty > 1) setState(() => _qty--); }),
                        Text('$_qty', style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.add_rounded, size: 18), onPressed: () => setState(() => _qty++)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _add,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFFFF6584), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.add_rounded, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final item = items[i];
                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(16)),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_rounded, color: Colors.white),
                  ),
                  onDismissed: (_) { widget.state.deleteShoppingItem(item.id); setState(() {}); },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                    ),
                    child: ListTile(
                      leading: GestureDetector(
                        onTap: () { widget.state.toggleShoppingItem(item.id); setState(() {}); },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: item.isBought ? const Color(0xFFFF6584) : Colors.transparent,
                            border: Border.all(color: item.isBought ? const Color(0xFFFF6584) : Colors.grey.shade300, width: 2),
                            shape: BoxShape.circle,
                          ),
                          child: item.isBought ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          decoration: item.isBought ? TextDecoration.lineThrough : null,
                          color: item.isBought ? Colors.grey : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6584).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('x${item.quantity}', style: const TextStyle(color: Color(0xFFFF6584), fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                );
              },
              childCount: items.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

// ─── Notes Screen ─────────────────────────────────────────
class NotesScreen extends StatefulWidget {
  final AppState state;
  const NotesScreen({super.key, required this.state});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _noteColors = [
    const Color(0xFFFFF176),
    const Color(0xFFB2EBF2),
    const Color(0xFFF8BBD0),
    const Color(0xFFC8E6C9),
    const Color(0xFFE1BEE7),
    const Color(0xFFFFCCBC),
  ];

  void _openNoteEditor({Note? note}) {
    final titleCtrl = TextEditingController(text: note?.title ?? '');
    final contentCtrl = TextEditingController(text: note?.content ?? '');
    Color selectedColor = note?.color ?? _noteColors[0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          height: MediaQuery.of(context).viewInsets.bottom + 500,
          decoration: BoxDecoration(
            color: selectedColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 20, right: 20, top: 16,
          ),
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                decoration: const InputDecoration(hintText: 'Başlık...', border: InputBorder.none),
              ),
              const Divider(),
              Expanded(
                child: TextField(
                  controller: contentCtrl,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(hintText: 'Not yaz...', border: InputBorder.none),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ..._noteColors.map((c) => GestureDetector(
                    onTap: () => setModalState(() => selectedColor = c),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(color: selectedColor == c ? Colors.black54 : Colors.transparent, width: 2),
                      ),
                    ),
                  )),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black87, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      if (titleCtrl.text.trim().isEmpty && contentCtrl.text.trim().isEmpty) { Navigator.pop(ctx); return; }
                      if (note == null) {
                        widget.state.addNote(Note(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleCtrl.text.trim().isEmpty ? 'Not' : titleCtrl.text.trim(),
                          content: contentCtrl.text.trim(),
                          color: selectedColor,
                          updatedAt: DateTime.now(),
                        ));
                      } else {
                        widget.state.updateNote(Note(
                          id: note.id,
                          title: titleCtrl.text.trim().isEmpty ? 'Not' : titleCtrl.text.trim(),
                          content: contentCtrl.text.trim(),
                          color: selectedColor,
                          updatedAt: DateTime.now(),
                        ));
                      }
                      setState(() {});
                      Navigator.pop(ctx);
                    },
                    child: const Text('Kaydet'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = widget.state.notes;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: const Color(0xFFFFB300),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFB300), Color(0xFFFFCA28)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('📝 Notlarım', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                      Text('Düşüncelerini kaydet', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final note = notes[i];
                  return GestureDetector(
                    onTap: () => _openNoteEditor(note: note),
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Notu sil?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
                            TextButton(
                              onPressed: () { widget.state.deleteNote(note.id); setState(() {}); Navigator.pop(context); },
                              child: const Text('Sil', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: note.color,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(note.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                          Expanded(child: Text(note.content, style: const TextStyle(fontSize: 12, color: Colors.black54), overflow: TextOverflow.fade)),
                        ],
                      ),
                    ),
                  );
                },
                childCount: notes.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNoteEditor(),
        backgroundColor: const Color(0xFFFFB300),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni Not', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ─── Expense Screen ───────────────────────────────────────
class ExpenseScreen extends StatefulWidget {
  final AppState state;
  const ExpenseScreen({super.key, required this.state});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  bool _isIncome = false;
  String _category = 'Genel';

  final _categories = ['Genel', 'Yiyecek', 'Ulaşım', 'Eğlence', 'Sağlık', 'Ev', 'Giyim', 'Gelir'];
  final Map<String, IconData> _catIcons = {
    'Yiyecek': Icons.restaurant_rounded,
    'Ulaşım': Icons.directions_bus_rounded,
    'Eğlence': Icons.movie_outlined,
    'Sağlık': Icons.local_hospital_outlined,
    'Ev': Icons.home_outlined,
    'Giyim': Icons.checkroom_outlined,
    'Gelir': Icons.trending_up_rounded,
    'Genel': Icons.circle_outlined,
  };

  void _add() {
    if (_titleCtrl.text.trim().isEmpty || _amountCtrl.text.trim().isEmpty) return;
    widget.state.addExpense(Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      amount: double.tryParse(_amountCtrl.text.trim()) ?? 0,
      category: _category,
      date: DateTime.now(),
      isIncome: _isIncome,
    ));
    _titleCtrl.clear();
    _amountCtrl.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF43D17A),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2ECC71), Color(0xFF43D17A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('💰 Harcamalar', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _BalanceCard(label: 'Gelir', amount: s.totalIncome, color: Colors.white24),
                          const SizedBox(width: 12),
                          _BalanceCard(label: 'Gider', amount: s.totalExpense, color: Colors.white24),
                          const SizedBox(width: 12),
                          _BalanceCard(label: 'Bakiye', amount: s.balance, color: Colors.white38, isBold: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _titleCtrl,
                          decoration: InputDecoration(
                            hintText: 'Açıklama...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 110,
                        child: TextField(
                          controller: _amountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '₺ Tutar',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                          child: DropdownButton<String>(
                            value: _category,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (v) => setState(() => _category = v!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _isIncome = !_isIncome),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: _isIncome ? const Color(0xFF43D17A).withOpacity(0.15) : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(_isIncome ? Icons.add_rounded : Icons.remove_rounded, color: _isIncome ? const Color(0xFF43D17A) : Colors.red, size: 18),
                              const SizedBox(width: 4),
                              Text(_isIncome ? 'Gelir' : 'Gider', style: TextStyle(color: _isIncome ? const Color(0xFF43D17A) : Colors.red, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _add,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFF43D17A), borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.add_rounded, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final expense = s.expenses[i];
                return Dismissible(
                  key: Key(expense.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(16)),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_rounded, color: Colors.white),
                  ),
                  onDismissed: (_) { widget.state.deleteExpense(expense.id); setState(() {}); },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: expense.isIncome ? const Color(0xFF43D17A).withOpacity(0.12) : Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_catIcons[expense.category] ?? Icons.circle_outlined, color: expense.isIncome ? const Color(0xFF43D17A) : Colors.red, size: 20),
                      ),
                      title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(expense.category, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      trailing: Text(
                        '${expense.isIncome ? '+' : '-'}₺${expense.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: expense.isIncome ? const Color(0xFF43D17A) : Colors.red,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: s.expenses.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isBold;

  const _BalanceCard({required this.label, required this.amount, required this.color, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 2),
            Text('₺${amount.toStringAsFixed(0)}', style: TextStyle(color: Colors.white, fontWeight: isBold ? FontWeight.w900 : FontWeight.w600, fontSize: isBold ? 15 : 13)),
          ],
        ),
      ),
    );
  }
}
