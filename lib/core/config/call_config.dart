// core/config/call_config.dart
class CallConfig {
  const CallConfig._();
  static const String livekitUrl = 'wss://ece-chat-app-odjzdk84.livekit.cloud';

  /// LiveKit Cloud Development Token Server ID.
  ///
  /// Development/testing only.
  /// Never use this architecture for production authentication.
  static const String developmentTokenServerId = 'ecechatapp-vq2jqq';

  /// Test room used only by the LiveKit foundation test screen.
  static const String testRoomName = 'ece_foundation_test_room';
  // Never put the API secret here — it stays server-side only,
  // inside the Cloud Function that issues tokens.
  // static const String tokenEndpoint =
  //     'https://your-region-your-project.cloudfunctions.net/createLiveKitToken';
}
