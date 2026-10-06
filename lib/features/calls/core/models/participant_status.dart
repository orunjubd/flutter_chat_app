enum ParticipantStatus { invited, joined, declined, left, missed }

extension ParticipantStatusX on ParticipantStatus {
  static ParticipantStatus parse(String? v) => ParticipantStatus.values
      .firstWhere((s) => s.name == v, orElse: () => ParticipantStatus.invited);
}
