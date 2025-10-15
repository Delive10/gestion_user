import 'package:flutter/material.dart';
import 'pages/dashboard.dart';
import 'pages/interested_list.dart';
import 'pages/scan_qr.dart';
import 'pages/tables.dart';
import 'pages/compte_protocole.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeWithBottomNav(), // changed to new home with bottom nav
    );
  }
}

class HomeWithBottomNav extends StatefulWidget {
  const HomeWithBottomNav({super.key});

  @override
  State<HomeWithBottomNav> createState() => _HomeWithBottomNavState();
}

class _HomeWithBottomNavState extends State<HomeWithBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    InterestedListPage(),
    ScanQrPage(),
    TablesPage(),
    CompteProtocolePage(),
  ];

  final List<String> _titles = const [
    'Dashboard',
    'Liste intéressés',
    'Scan QR',
    'Tables',
    'Compte Protocole',
  ];

  void _onTap(int idx) {
    setState(() {
      _currentIndex = idx;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Intéressés'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan QR'),
          BottomNavigationBarItem(icon: Icon(Icons.table_chart), label: 'Tables'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Compte'),
        ],
      ),
    );
  }
}
