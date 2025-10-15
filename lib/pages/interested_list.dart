import 'package:flutter/material.dart';

class InterestedListPage extends StatefulWidget {
  const InterestedListPage({super.key});

  @override
  State<InterestedListPage> createState() => _InterestedListPageState();
}

class _InterestedListPageState extends State<InterestedListPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _allNames = [
    'ABILI MWAMBELA Samuel',
    'ABRAHAM MOYO ULENGI',
    'ABUZEA EBUMEA Belange',
    'AGOUSSI YAPO GUILLAUME',
    'AIMÉ NKUNNKU LUTUMBA',
    'AKEM',
    // ... ajoutez d'autres noms si nécessaire
  ];
  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = List.from(_allNames);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = List.from(_allNames);
      } else {
        _filtered = _allNames.where((n) => n.toLowerCase().contains(q)).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  String _initials(String name) {
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header similaire à l'image (icone + titre + filtre)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.person, color: Colors.black54),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Liste des invités',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  // action filtre - à implémenter
                },
              )
            ],
          ),
        ),

        // Barre de recherche
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un invité',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade200,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Liste des invités
        Expanded(
          child: _filtered.isEmpty
              ? Center(
                  child: Text(
                    'Aucun invité trouvé',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final name = _filtered[index];
                    return InkWell(
                      onTap: () {
                        // action sur tap : ouvrir détails, etc.
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Appuyé sur: $name')),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            // avatar avec initiales
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey.shade300,
                              child: Text(
                                _initials(name),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // nom et sous-texte
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text('Tap pour voir les détails', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                ],
                              ),
                            ),

                            // action rapide
                            IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () {
                                // action menu - à implémenter
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}