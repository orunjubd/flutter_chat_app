//import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

//import 'package:chat_app/core/services/connectivity_service.dart';

// final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
//   return ConnectivityService();
// });

final connectivityProvider =
    StreamProvider.autoDispose<List<ConnectivityResult>>((ref) async* {
      final connectivity = Connectivity();

      // Emit current status immediately.
      yield await connectivity.checkConnectivity();

      // Continue listening for future changes.
      yield* connectivity.onConnectivityChanged;
    });
