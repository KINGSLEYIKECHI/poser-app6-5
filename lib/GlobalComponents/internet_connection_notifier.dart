import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final internetConnectionProvider = ChangeNotifierProvider<InternetConnectionNotifier>((ref) {
  return InternetConnectionNotifier();
});

class InternetConnectionNotifier extends ChangeNotifier with WidgetsBindingObserver {
  bool _isConnected = true;
  AppLifecycleState appLifecycleState = AppLifecycleState.resumed;
  late final StreamSubscription<InternetStatus> _subscription;

  bool get isConnected => _isConnected;

  InternetConnectionNotifier() {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  void _init() {
    checkConnection();
    _subscription = InternetConnection().onStatusChange.listen((status) {
      print('Internet connection status: $status');
      if (appLifecycleState != AppLifecycleState.paused) {
        final wasConnected = _isConnected;
        _isConnected = status == InternetStatus.connected;
        notifyListeners();
      }
    });
  }

  Future<void> checkConnection() async {
    final previous = _isConnected;
    _isConnected = await InternetConnection().hasInternetAccess;
    if (_isConnected != previous) notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    appLifecycleState = state;
    notifyListeners();
    if (state == AppLifecycleState.resumed) {
      checkConnection();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription.cancel();
    super.dispose();
  }
}
