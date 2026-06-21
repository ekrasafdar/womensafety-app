import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _seedData();
  }

  // ---- Auth (mock, in-memory "database") ----
  final Map<String, String> _registeredUsers = {
    'demo@safeguard.app': 'demo1234',
  };
  final Map<String, String> _userNames = {
    'demo@safeguard.app': 'Demo User',
  };
  AppUser? currentUser;

  String? signUp({required String name, required String email, required String password}) {
    final key = email.trim().toLowerCase();
    if (_registeredUsers.containsKey(key)) {
      return 'An account with this email already exists.';
    }
    _registeredUsers[key] = password;
    _userNames[key] = name.trim();
    currentUser = AppUser(name: name.trim(), email: key);
    notifyListeners();
    return null;
  }

  String? logIn({required String email, required String password}) {
    final key = email.trim().toLowerCase();
    if (!_registeredUsers.containsKey(key)) {
      return 'No account found with this email.';
    }
    if (_registeredUsers[key] != password) {
      return 'Incorrect password.';
    }
    currentUser = AppUser(name: _userNames[key] ?? 'User', email: key);
    notifyListeners();
    return null;
  }

  String? resetPassword({required String email}) {
    final key = email.trim().toLowerCase();
    if (!_registeredUsers.containsKey(key)) {
      return 'No account found with this email.';
    }
    return null; // simulated: reset link "sent"
  }

  void logOut() {
    currentUser = null;
    notifyListeners();
  }

  // ---- Trusted contacts ----
  final List<TrustedContact> contacts = [];

  void addContact(TrustedContact c) {
    contacts.add(c);
    notifyListeners();
  }

  void removeContact(String id) {
    contacts.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // ---- Emergency / alert history ----
  final List<AlertRecord> history = [];

  void addAlert(AlertRecord a) {
    history.insert(0, a);
    notifyListeners();
  }

  // ---- Live location ----
  double? currentLat;
  double? currentLng;
  bool isSharingLocation = false;
  String locationStatus = 'Location not started';

  Future<void> refreshLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final req = await Geolocator.requestPermission();
        if (req == LocationPermission.denied ||
            req == LocationPermission.deniedForever) {
          locationStatus = 'Location permission denied';
          notifyListeners();
          return;
        }
      }
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationStatus = 'Location services are off';
        notifyListeners();
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentLat = pos.latitude;
      currentLng = pos.longitude;
      locationStatus = 'Location active';
    } catch (e) {
      locationStatus = 'Could not get location (using simulated demo location)';
      currentLat ??= 30.1575 + Random().nextDouble() * 0.01;
      currentLng ??= 71.5249 + Random().nextDouble() * 0.01;
    }
    notifyListeners();
  }

  void toggleSharing(bool value) {
    isSharingLocation = value;
    notifyListeners();
  }

  // ---- SOS ----
  bool sosActive = false;

  Future<void> triggerSOS() async {
    sosActive = true;
    notifyListeners();
    await refreshLocation();
    addAlert(AlertRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: AlertType.sos,
      time: DateTime.now(),
      lat: currentLat ?? 0,
      lng: currentLng ?? 0,
      note: 'Live location shared with ${contacts.length} trusted contact(s).',
    ));
  }

  void cancelSOS() {
    sosActive = false;
    notifyListeners();
  }

  // ---- Safety monitoring (simple AI-style risk score) ----
  bool monitoringEnabled = true;
  double riskScore = 0.18;
  Timer? _riskTimer;

  void startMonitoring() {
    _riskTimer?.cancel();
    _riskTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!monitoringEnabled) return;
      final hour = DateTime.now().hour;
      final isNight = hour >= 22 || hour <= 5;
      final base = isNight ? 0.35 : 0.15;
      riskScore = (base + Random().nextDouble() * 0.3).clamp(0.0, 1.0);
      if (riskScore > 0.75) {
        addAlert(AlertRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: AlertType.inactivity,
          time: DateTime.now(),
          lat: currentLat ?? 0,
          lng: currentLng ?? 0,
          note: 'Risk score exceeded threshold (${(riskScore * 100).toStringAsFixed(0)}%). Safety check triggered.',
        ));
      }
      notifyListeners();
    });
  }

  void stopMonitoring() {
    _riskTimer?.cancel();
  }

  // ---- Route monitoring ----
  String? destinationName;
  double routeDeviationPercent = 0.0;

  void setDestination(String name) {
    destinationName = name;
    routeDeviationPercent = 0;
    notifyListeners();
  }

  void simulateDeviation() {
    routeDeviationPercent = (routeDeviationPercent + Random().nextInt(40) + 10)
        .clamp(0, 100)
        .toDouble();
    if (routeDeviationPercent > 60) {
      addAlert(AlertRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: AlertType.routeDeviation,
        time: DateTime.now(),
        lat: currentLat ?? 0,
        lng: currentLng ?? 0,
        note: 'Deviated ${routeDeviationPercent.toStringAsFixed(0)}% from expected route to $destinationName.',
      ));
    }
    notifyListeners();
  }

  void _seedData() {
    contacts.addAll([
      TrustedContact(id: '1', name: 'Ayesha Khan', phone: '+92 300 1234567', relation: 'Sister'),
      TrustedContact(id: '2', name: 'Bilal Ahmed', phone: '+92 321 7654321', relation: 'Friend'),
    ]);
    history.addAll([
      AlertRecord(
        id: 'h1',
        type: AlertType.sos,
        time: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
        lat: 30.1575,
        lng: 71.5249,
        note: 'Live location shared with 2 trusted contacts.',
      ),
      AlertRecord(
        id: 'h2',
        type: AlertType.routeDeviation,
        time: DateTime.now().subtract(const Duration(days: 5)),
        lat: 30.1600,
        lng: 71.5300,
        note: 'Deviated 68% from expected route to Home.',
      ),
    ]);
  }

  @override
  void dispose() {
    _riskTimer?.cancel();
    super.dispose();
  }
}
