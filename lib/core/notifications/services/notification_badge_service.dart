import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/foundation.dart';

class NotificationBadgeService {
  int _last = -1;
  bool? _supported;

  Future<void> update(int count) async {
    debugPrint(
      '🏷️ [BADGE DEBUG] Supported: $_supported | Unread Count: $count',
    );
    if (count == _last) return;
    _last = count;
    try {
      _supported ??= await AppBadgePlus.isSupported();
      if (_supported != true) return;
      await AppBadgePlus.updateBadge(count);
    } catch (e) {
      debugPrint('⚠️ [Notify] badge failed: $e');
    }
  }
}
