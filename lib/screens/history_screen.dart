import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../data/app_state.dart';
import '../models/models.dart';

class HistoryScreen extends StatefulWidget {
  final AppState state;
  const HistoryScreen({super.key, required this.state});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    widget.state.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.state.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => mounted ? setState(() {}) : null;

  IconData _iconFor(AlertType t) {
    switch (t) {
      case AlertType.sos:
        return Icons.sos_rounded;
      case AlertType.routeDeviation:
        return Icons.alt_route_rounded;
      case AlertType.inactivity:
        return Icons.monitor_heart_rounded;
      case AlertType.manualCheck:
        return Icons.check_circle_outline_rounded;
    }
  }

  Color _colorFor(AlertType t) {
    switch (t) {
      case AlertType.sos:
        return AppColors.danger;
      case AlertType.routeDeviation:
        return AppColors.warning;
      case AlertType.inactivity:
        return AppColors.primary;
      case AlertType.manualCheck:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = widget.state.history;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Emergency History', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Record of past alerts, time and location.',
                style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Expanded(
              child: history.isEmpty
                  ? const Center(child: Text('No alerts yet.', style: TextStyle(color: AppColors.textSecondary)))
                  : ListView.separated(
                      itemCount: history.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final a = history[i];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _colorFor(a.type).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(_iconFor(a.type), color: _colorFor(a.type)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 4),
                                    Text(a.note, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    Text(
                                      DateFormat('MMM d, y · h:mm a').format(a.time),
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
