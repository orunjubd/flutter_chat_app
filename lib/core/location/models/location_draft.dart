class LocationDraft {
  const LocationDraft({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  final double latitude;
  final double longitude;
  final String? address;

  LocationDraft copyWith({
    double? latitude,
    double? longitude,
    String? address,
  }) {
    return LocationDraft(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
    );
  }
}
