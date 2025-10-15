import 'package:flutter/material.dart';

const Color _primaryColor = Color(0xFF296239);

class CompteProtocolePage extends StatefulWidget {
  const CompteProtocolePage({super.key});

  @override
  State<CompteProtocolePage> createState() => _CompteProtocolePageState();
}

class _CompteProtocolePageState extends State<CompteProtocolePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController(text: 'Jean Dupont');
  final TextEditingController _emailCtrl = TextEditingController(text: 'jean.dupont@example.com');
  final TextEditingController _phoneCtrl = TextEditingController(text: '+243 99 123 4567');

  bool _editing = false;

  final Map<String, bool> _protocols = {
    'Protocole A': true,
    'Protocole B': false,
    'Protocole C': true,
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String _initials(String name) {
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  void _toggleEdit() {
    setState(() {
      _editing = !_editing;
    });
    if (!_editing) {
      // cancelling edit: optionally reset fields or keep changes
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil enregistré')));
    }
  }

  Future<void> _resetPassword() async {
    await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Réinitialiser le mot de passe'),
        content: const Text('Un lien de réinitialisation a été envoyé à votre adresse email (simulation).'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  void _signOut() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Déconnexion (simulation)')));
    // ici rediriger vers l'écran de login si nécessaire
  }

  @override
  Widget build(BuildContext context) {
    final name = _nameCtrl.text;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header profile card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: _primaryColor,
                      child: Text(_initials(name), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(_emailCtrl.text, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(_editing ? Icons.close : Icons.edit),
                      onPressed: _toggleEdit,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Form
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        enabled: _editing,
                        decoration: const InputDecoration(labelText: 'Nom complet', prefixIcon: Icon(Icons.person)),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Le nom est requis' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailCtrl,
                        enabled: _editing,
                        decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'L\'email est requis';
                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) return 'Email invalide';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneCtrl,
                        enabled: _editing,
                        decoration: const InputDecoration(labelText: 'Téléphone', prefixIcon: Icon(Icons.phone)),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (_editing)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _saveProfile,
                                icon: const Icon(Icons.save),
                                label: const Text('Enregistrer'),
                              ),
                            )
                          else
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _resetPassword,
                                icon: const Icon(Icons.lock_reset),
                                label: const Text('Réinitialiser mot de passe'),
                              ),
                            ),
                          const SizedBox(width: 8),
                          if (!_editing)
                            ElevatedButton.icon(
                              onPressed: _signOut,
                              icon: const Icon(Icons.logout),
                              label: const Text('Déconnexion'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Protocoles
            Expanded(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Protocoles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _protocols.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final key = _protocols.keys.elementAt(index);
                            final val = _protocols.values.elementAt(index);
                            return SwitchListTile(
                              title: Text(key),
                              value: val,
                              onChanged: (v) {
                                setState(() {
                                  _protocols[key] = v;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$key ${v ? 'activé' : 'désactivé'}')));
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
