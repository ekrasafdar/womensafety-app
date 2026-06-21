import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/app_state.dart';

class SafetyScreen extends StatefulWidget {
  final AppState state;
  const SafetyScreen({super.key, required this.state});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  final destCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_refresh);
    widget.state.refreshLocation();
  }

  @override
  void dispose() {
    widget.state.removeListener(_refresh);
    destCtrl.dispose();
    super.dispose();
  }

  void _refresh() => mounted ? setState(() {}) : null;

  void _startFakeCall() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const FakeCallScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const Text('Safety Tools', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),

          // Live location card
          _SectionCard(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.primary,
            title: 'Live Location Sharing',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.currentLat != null
                      ? 'Lat ${s.currentLat!.toStringAsFixed(5)}, Lng ${s.currentLng!.toStringAsFixed(5)}'
                      : s.locationStatus,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(Icons.map_rounded, color: AppColors.textSecondary, size: 36),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.isSharingLocation ? 'Sharing with trusted contacts' : 'Sharing is off',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Switch(
                      value: s.isSharingLocation,
                      activeColor: AppColors.primary,
                      onChanged: (v) {
                        s.toggleSharing(v);
                        if (v) s.refreshLocation();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Monitoring
          _SectionCard(
            icon: Icons.monitor_heart_rounded,
            iconColor: AppColors.success,
            title: 'Safety Monitoring',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detects unusual movement/inactivity patterns and time-of-day risk automatically.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.monitoringEnabled ? 'Monitoring is active' : 'Monitoring is paused',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Switch(
                      value: s.monitoringEnabled,
                      activeColor: AppColors.success,
                      onChanged: (v) {
                        s.monitoringEnabled = v;
                        if (v) {
                          s.startMonitoring();
                        } else {
                          s.stopMonitoring();
                        }
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Route monitoring
          _SectionCard(
            icon: Icons.alt_route_rounded,
            iconColor: AppColors.warning,
            title: 'Route Monitoring',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: destCtrl,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Set destination (e.g. Home)',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surfaceLight,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check, color: AppColors.primary),
                      onPressed: () {
                        if (destCtrl.text.trim().isNotEmpty) {
                          s.setDestination(destCtrl.text.trim());
                        }
                      },
                    ),
                  ),
                ),
                if (s.destinationName != null) ...[
                  const SizedBox(height: 12),
                  Text('Destination: ${s.destinationName}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: s.routeDeviationPercent / 100,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: AlwaysStoppedAnimation(
                        s.routeDeviationPercent > 60 ? AppColors.danger : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('${s.routeDeviationPercent.toStringAsFixed(0)}% deviation from expected route',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: s.simulateDeviation,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.surfaceLight),
                    ),
                    child: const Text('Simulate movement update'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Fake call
          _SectionCard(
            icon: Icons.phone_in_talk_rounded,
            iconColor: AppColors.dangerDark,
            title: 'Fake Call',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Simulate an incoming call to help you exit an uncomfortable situation.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _startFakeCall,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceLight,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.call_rounded),
                    label: const Text('Trigger Fake Call in 3s'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;
  const _SectionCard({required this.icon, required this.iconColor, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class FakeCallScreen extends StatefulWidget {
  const FakeCallScreen({super.key});

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen> {
  bool ringing = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => ringing = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            children: [
              const Spacer(),
              const CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.surfaceLight,
                child: Icon(Icons.person, size: 60, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              const Text('Mom', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(ringing ? 'Incoming call...' : 'Connecting...',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _callButton(Icons.call_end_rounded, AppColors.danger, () => Navigator.pop(context)),
                  _callButton(Icons.call_rounded, AppColors.success, () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _callButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}
