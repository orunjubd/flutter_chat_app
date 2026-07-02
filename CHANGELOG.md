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

# Changelog

## v1.2.2

### Added
- Email verification support after successful account registration.
- Centralized `AuthExceptionMapper` for translating Firebase Authentication errors into user-friendly messages.

### Changed
- Registration workflow now automatically sends a verification email.
- Authentication UI now displays mapped application errors instead of raw Firebase error messages.

### Improved
- Simplified authentication error handling.
- Removed duplicated Firebase exception logic from the UI layer.
- Increased separation of concerns between presentation and authentication services.

# v1.2.3 — Email Verification Gate

## Added

* Email verification workflow
* VerifyEmailScreen
* Refresh verification button
* Resend verification button
* Email verification repository methods
* Email verification provider
* Email verification routing via AuthGate

## Improved

* Authentication flow now prevents unverified users from accessing ChatScreen.
* Repository abstraction expanded with email verification APIs.
* Riverpod provider invalidation used to refresh verification state.

## Tested

* New account registration
* Firestore user creation
* Authentication login
* Email verification
* Refresh verification
* Logout
* Verified user login
* Authentication routing

Status:
Authentication module is fully functional and verified.
