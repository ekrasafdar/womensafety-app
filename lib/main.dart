import 'package:flutter/material.dart';
import 'theme.dart';
import 'data/app_state.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/contacts_screen.dart';
import 'screens/safety_screen.dart';
import 'screens/history_screen.dart';

void main() {
  runApp(const SafeGuardApp());
}

class SafeGuardApp extends StatelessWidget {
  const SafeGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const RootGate(),
    );
  }
}

class RootGate extends StatefulWidget {
  const RootGate({super.key});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  final AppState _state = AppState();

  @override
  void initState() {
    super.initState();
    _state.addListener(_onChange);
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _state.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_state.currentUser == null) {
      return AuthScreen(state: _state, onAuthenticated: () => setState(() {}));
    }
    return RootNav(state: _state);
  }
}

class RootNav extends StatefulWidget {
  final AppState state;
  const RootNav({super.key, required this.state});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final screens = [
      HomeScreen(state: s),
      SafetyScreen(state: s),
      ContactsScreen(state: s),
      HistoryScreen(state: s),
    ];

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: screens[_index],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.surfaceBorder, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.shield_rounded), label: 'Safety'),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Contacts'),
            BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
          ],
        ),
      ),
    );
  }
}
