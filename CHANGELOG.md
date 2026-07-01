# Changelog

## v1.2.0

### Added

- Firebase Authentication
- Firestore User Profile
- Repository Pattern
- Riverpod Providers
- RegistrationService V1
- Auth Listener
- Logout
- ChatScreen Skeleton

### Changed

- Authentication architecture migrated to Feature-First design.

### Fixed

- Firestore permission issue
- Registration flow cleanup

# Changelog

## v1.2.1

### Added
- Production-safe RegistrationService
- Firebase Authentication rollback support
- AppUser returned from RegistrationService
- RegistrationService V2

### Changed
- Registration workflow refactored into transaction-safe service

### Fixed
- Prevent inconsistent Authentication and Firestore data when registration fails