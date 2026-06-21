class AppUser {
  final String name;
  final String email;

  AppUser({required this.name, required this.email});
}

class TrustedContact {
  final String id;
  String name;
  String phone;
  String relation;

  TrustedContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
  });
}

enum AlertType { sos, routeDeviation, inactivity, manualCheck }

class AlertRecord {
  final String id;
  final AlertType type;
  final DateTime time;
  final double lat;
  final double lng;
  final String note;

  AlertRecord({
    required this.id,
    required this.type,
    required this.time,
    required this.lat,
    required this.lng,
    required this.note,
  });

  String get title {
    switch (type) {
      case AlertType.sos:
        return 'SOS Alert Sent';
      case AlertType.routeDeviation:
        return 'Route Deviation Detected';
      case AlertType.inactivity:
        return 'Inactivity Safety Check';
      case AlertType.manualCheck:
        return 'Manual Safety Check';
    }
  }
}
