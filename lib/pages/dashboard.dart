import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // valeurs d'exemple (remplacez par vos données réelles)
    final int totalInvites = 606;
    final int invitesRecus = 0;
    final int invitesAttente = totalInvites - invitesRecus;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Grille 2x2 de cartes
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _StatCard(
                color: Colors.green.shade100,
                icon: Icons.people,
                title: "Nombre total d'invités",
                value: totalInvites.toString(),
              ),
              _StatCard(
                color: Colors.blue.shade100,
                icon: Icons.check_circle,
                title: "Nombre d'invités reçus",
                value: invitesRecus.toString(),
              ),
              _StatCard(
                color: Colors.red.shade100,
                icon: Icons.hourglass_top,
                title: "Nombre d'invités en attente",
                value: invitesAttente.toString(),
              ),
              _StatCard(
                color: Colors.orange.shade100,
                icon: Icons.table_bar,
                title: "Nombre de tables",
                value: '1',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Carte pour le graphique circulaire + légende
          Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Zone du "pie chart"
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CustomPaint(
                      painter: PieChartPainter(
                        values: [invitesAttente.toDouble(), invitesRecus.toDouble()],
                        colors: [Colors.redAccent, Colors.lightBlueAccent],
                      ),
                      child: Center(
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 4)
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${((invitesAttente / (totalInvites == 0 ? 1 : totalInvites)) * 100).round()}%',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Légende
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LegendItem(
                            color: Colors.redAccent, label: 'Invités en attente'),
                        const SizedBox(height: 8),
                        _LegendItem(
                            color: Colors.lightBlueAccent,
                            label: 'Invités reçus'),
                        const SizedBox(height: 12),
                        Text(
                          '$totalInvites invit${totalInvites > 1 ? 's' : ''} au total',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey[700]),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget pour chaque carte statistique
class _StatCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 20, color: Colors.black54),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget de ligne de légende
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}

// Simple CustomPainter pour dessiner un "pie" à partir de valeurs
class PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  PieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (a, b) => a + b);
    final rect = Offset.zero & size;
    final paint = Paint()..style = PaintingStyle.fill;

    double startAngle = -90 * 3.1415926535 / 180; // start at top

    for (int i = 0; i < values.length; i++) {
      final sweep = (total == 0) ? (2 * 3.1415926535 * (i == 0 ? 1.0 : 0.0)) : (values[i] / total) * 2 * 3.1415926535;
      paint.color = colors[i % colors.length];
      canvas.drawArc(rect.deflate(8), startAngle, sweep, true, paint);
      startAngle += sweep;
    }

    // petit cercle blanc central pour effet donut
    final center = Offset(size.width / 2, size.height / 2);
    final holePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, size.width * 0.18, holePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
