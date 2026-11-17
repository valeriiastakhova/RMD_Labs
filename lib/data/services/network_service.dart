import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  final Connectivity _connectivity = Connectivity();

  // Разова перевірка наявності інтернету (для екрану логіну та автологіну)
  Future<bool> hasConnection() async {
    final results = await _connectivity.checkConnectivity();
    return _isConnected(results);
  }

  // Потік (Stream) змін стану мережі в реальному часі
  Stream<bool> get onConnectionChange {
    return _connectivity.onConnectivityChanged.map(_isConnected).distinct();
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet,
    );
  }
}
