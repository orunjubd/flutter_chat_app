import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:flutter_riverpod/legacy.dart';
import '../data/repositories/auth_repository.dart';

// 🚀 B. Globally accessible provider instance mapping
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// 🚀 C. State controller to manage UI loading indicators (Async states)
class AuthLoadingNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  } // Initial state is NOT loading

  void setLoading(bool value) => state = value;
}

final authLoadingProvider = NotifierProvider<AuthLoadingNotifier, bool>(
  AuthLoadingNotifier.new,
);
