import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService();

  final Connectivity _connectivity = Connectivity();

  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  Future<List<ConnectivityResult>> checkConnection() {
    return _connectivity.checkConnectivity();
  }
}
