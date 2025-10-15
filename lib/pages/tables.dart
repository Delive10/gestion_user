import 'package:flutter/material.dart';

// modèle simple pour une table (top-level, pas imbriqué)
class _TableItem {
  String name;
  int capacity;
  int guests;
  bool occupied;
  _TableItem({
    required this.name,
    required this.capacity,
    this.guests = 0,
    this.occupied = false,
  });
}

// Page de liste / gestion des tables
class TablesPage extends StatefulWidget {
  const TablesPage({super.key});

  @override
  State<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = 'Tous';

  // données d'exemple
  final List<_TableItem> _allTables = [
    _TableItem(name: 'Table 1', capacity: 8, guests: 2, occupied: true),
    _TableItem(name: 'Table 2', capacity: 6, guests: 0, occupied: false),
    _TableItem(name: 'Table 3', capacity: 4, guests: 4, occupied: true),
    _TableItem(name: 'Table VIP', capacity: 10, guests: 0, occupied: false),
  ];

  List<_TableItem> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = List.from(_allTables);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() => _applyFilters();

  void _applyFilters() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _filtered = _allTables.where((t) {
        final matchesFilter = (_filter == 'Tous') ||
            (_filter == 'Occupées' && t.occupied) ||
            (_filter == 'Libres' && !t.occupied);
        final matchesQuery = q.isEmpty || t.name.toLowerCase().contains(q);
        return matchesFilter && matchesQuery;
      }).toList();
    });
  }

  Future<void> _showTableDialog({_TableItem? item}) async {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final capCtrl = TextEditingController(text: item?.capacity.toString() ?? '4');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Ajouter une table' : 'Éditer la table'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nom')),
            TextField(
              controller: capCtrl,
              decoration: const InputDecoration(labelText: 'Capacité'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Valider')),
        ],
      ),
    );

    if (result == true) {
      final name = nameCtrl.text.trim();
      final capacity = int.tryParse(capCtrl.text.trim()) ?? 1;
      setState(() {
        if (item == null) {
          _allTables.add(_TableItem(name: name.isEmpty ? 'Nouvelle table' : name, capacity: capacity));
        } else {
          item.name = name.isEmpty ? item.name : name;
          item.capacity = capacity;
        }
        _applyFilters();
      });
    }
  }

  void _deleteTable(_TableItem item) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Supprimer la table'),
        content: Text('Supprimer "${item.name}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _allTables.remove(item);
                _applyFilters();
              });
              Navigator.of(c).pop();
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Note: si cette page est déjà utilisée dans un parent Scaffold, vous pouvez retirer l'appBar ici.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header + filtre
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.table_chart, color: Colors.black87),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Gestion des tables', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _filter,
                    items: const [
                      DropdownMenuItem(value: 'Tous', child: Text('Tous')),
                      DropdownMenuItem(value: 'Occupées', child: Text('Occupées')),
                      DropdownMenuItem(value: 'Libres', child: Text('Libres')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _filter = v);
                      _applyFilters();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Search
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher une table',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 12),

              // Liste
              Expanded(
                child: _filtered.isEmpty
                    ? Center(child: Text('Aucune table', style: TextStyle(color: Colors.grey[600])))
                    : ListView.separated(
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final t = _filtered[index];
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: t.occupied ? Colors.redAccent : Colors.green,
                                child: Text(
                                  t.name.split(' ').lastWhere((s) => s.isNotEmpty, orElse: () => '${index + 1}'),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text('Capacité: ${t.capacity} • Invités: ${t.guests}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Chip(
                                    label: Text(t.occupied ? 'Occupée' : 'Libre'),
                                    backgroundColor: t.occupied ? Colors.red.shade50 : Colors.green.shade50,
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'edit') _showTableDialog(item: t);
                                      if (value == 'toggle') {
                                        setState(() {
                                          t.occupied = !t.occupied;
                                          if (!t.occupied) t.guests = 0;
                                        });
                                        _applyFilters();
                                      }
                                      if (value == 'delete') _deleteTable(t);
                                    },
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(value: 'edit', child: Text('Éditer')),
                                      PopupMenuItem(value: 'toggle', child: Text(t.occupied ? 'Marquer libre' : 'Marquer occupée')),
                                      const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                // action sur tap : basculer occupied pour demo
                                setState(() {
                                  t.occupied = !t.occupied;
                                  if (!t.occupied) t.guests = 0;
                                });
                                _applyFilters();
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTableDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
