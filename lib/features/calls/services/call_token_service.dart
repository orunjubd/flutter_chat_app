import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:chat_app/core/config/call_config.dart';

class CallTokenService {
  const CallTokenService();

  /// Requests a temporary development token from LiveKit Cloud.
  ///
  /// This service is ONLY for Phase 4.9.1 foundation testing.
  /// Production will use our authenticated backend token endpoint.
  Future<TokenSourceResponse> fetchDevelopmentToken({
    required String roomName,
    required String participantIdentity,
  }) async {
    final tokenSource = DevelopmentTokenSource(
      id: CallConfig.developmentTokenServerId,
    );

    debugPrint('🔐 [CallTokenService] Requesting development token...');
    debugPrint('🏠 [CallTokenService] Room: $roomName');
    debugPrint('👤 [CallTokenService] Identity: $participantIdentity');

    final response = await tokenSource.fetch(
      TokenRequestOptions(
        roomName: roomName,
        participantIdentity: participantIdentity,
      ),
    );

    debugPrint('✅ [CallTokenService] Development token received.');

    return response;
  }
}
