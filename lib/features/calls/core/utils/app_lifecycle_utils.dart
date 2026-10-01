import 'package:flutter/widgets.dart';

/// Single source of truth for "is our own UI allowed to handle this call?".
/// Used by both CallController and GlobalIncomingCallListener so they can
/// never disagree.
bool get isAppInForeground =>
    WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
