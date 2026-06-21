import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/app_state.dart';

class HomeScreen extends StatefulWidget {
  final AppState state;
  const HomeScreen({super.key, required this.state});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    widget.state.startMonitoring();
    widget.state.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.state.removeListener(_onStateChanged);
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleSOSPress() async {
    if (widget.state.sosActive) {
      _showCancelSheet();
      return;
    }
    await widget.state.triggerSOS();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        content: const Text('SOS sent! Trusted contacts notified with your live location.'),
      ),
    );
  }

  void _showCancelSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 40),
            const SizedBox(height: 12),
            const Text('SOS is currently active', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text(
              'Your trusted contacts are receiving live location updates.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceLight,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  widget.state.cancelSOS();
                  Navigator.pop(context);
                },
                child: const Text("I'm safe — Cancel SOS"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _riskColor {
    final r = widget.state.riskScore;
    if (r < 0.35) return AppColors.success;
    if (r < 0.7) return AppColors.warning;
    return AppColors.danger;
  }

  String get _riskLabel {
    final r = widget.state.riskScore;
    if (r < 0.35) return 'Low Risk';
    if (r < 0.7) return 'Elevated Risk';
    return 'High Risk';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, ${(s.currentUser?.name ?? 'there').split(' ').first} 👋',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    const Text('You are protected', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
                PopupMenuButton<String>(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  onSelected: (v) {
                    if (v == 'logout') s.logOut();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded, color: AppColors.danger, size: 18),
                          SizedBox(width: 10),
                          Text('Log out'),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        (s.currentUser?.name.isNotEmpty == true ? s.currentUser!.name[0] : '?').toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Risk score card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: s.riskScore,
                          strokeWidth: 6,
                          backgroundColor: AppColors.surfaceLight,
                          valueColor: AlwaysStoppedAnimation(_riskColor),
                        ),
                        Text('${(s.riskScore * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_riskLabel, style: TextStyle(fontWeight: FontWeight.w700, color: _riskColor, fontSize: 16)),
                        const SizedBox(height: 4),
                        const Text(
                          'AI safety score from time, movement & route data',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // SOS button
            Center(
              child: GestureDetector(
                onTap: _handleSOSPress,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final pulse = s.sosActive ? (0.9 + 0.2 * (_pulseController.value)) : 1.0;
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (s.sosActive ? AppColors.danger : AppColors.dangerDark)
                                .withOpacity(0.45 * (s.sosActive ? pulse : 1)),
                            blurRadius: 40,
                            spreadRadius: s.sosActive ? 10 * pulse : 6,
                          ),
                        ],
                        gradient: const LinearGradient(
                          colors: [AppColors.danger, AppColors.dangerDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(s.sosActive ? Icons.notifications_active_rounded : Icons.touch_app_rounded,
                              color: Colors.white, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            s.sosActive ? 'SOS ACTIVE' : 'PRESS FOR SOS',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                s.sosActive ? 'Tap to cancel SOS' : 'Sends your live location to trusted contacts',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),

            const SizedBox(height: 36),

            // Quick stats row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.people_alt_rounded,
                    label: 'Trusted Contacts',
                    value: '${s.contacts.length}',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _StatCard(
                    icon: Icons.history_rounded,
                    label: 'Past Alerts',
                    value: '${s.history.length}',
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
