import 'package:cloud_firestore/cloud_firestore.dart';

class GlobalNotificationSettings {
  const GlobalNotificationSettings({this.mutedUntil, this.messageSound = true});
  final Timestamp? mutedUntil;
  final bool messageSound;

  bool get isMuted =>
      mutedUntil != null && mutedUntil!.toDate().isAfter(DateTime.now());

  factory GlobalNotificationSettings.fromMap(Map<String, dynamic>? d) =>
      GlobalNotificationSettings(
        mutedUntil: d?['mutedUntil'] as Timestamp?,
        messageSound: d?['messageSound'] as bool? ?? true,
      );
}
