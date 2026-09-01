// lib/features/peoples/models/people_sort_option.dart
enum PeopleSortOption { nameAsc, nameDesc, onlineFirst }

extension PeopleSortOptionLabel on PeopleSortOption {
  String get label => switch (this) {
    PeopleSortOption.nameAsc => 'Name (A–Z)',
    PeopleSortOption.nameDesc => 'Name (Z–A)',
    PeopleSortOption.onlineFirst => 'Online first',
  };
}
