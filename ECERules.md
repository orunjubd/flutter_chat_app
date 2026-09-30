# ECE Engineering Rules

**Project:** ECE --- Enterprise Chat Engine\
**Document:** `ECERules.md`\
**Status:** Canonical Engineering Rules

------------------------------------------------------------------------

## 1. ECE Core Vision

ECE is an **Enterprise Chat Engine**, not a clone of an existing chat
application.

ECE is a reusable, modular foundation for building many kinds of
communication products, including:

-   Gaming Chat
-   Social Chat
-   Help / Support Chat
-   Business Chat
-   Messenger-style Chat
-   Community Chat
-   Education Chat
-   Financial / transactional communication
-   Internal Enterprise Chat
-   Future products not yet imagined

> **Build reusable engine capabilities first; build product-specific
> behavior on top of them.**

------------------------------------------------------------------------

## 2. Fully Customizable Product Architecture

An ECE-based product must be able to customize, where appropriate:

-   branding, name, logo
-   colors, typography, theme
-   navigation and UI
-   enabled features
-   permissions and roles
-   messaging policies
-   media/attachment limits
-   notifications
-   moderation
-   storage providers
-   product-specific workflows
-   admin policies

Product-specific assumptions must not be hard-coded into ECE Core.

------------------------------------------------------------------------

## 3. Admin Full Control

Administration is a first-class ECE capability.

The architecture must support explicit administration of:

-   users
-   roles
-   permissions
-   feature availability
-   message policies
-   attachment policies
-   media limits
-   moderation
-   reports
-   blocking/restrictions
-   system settings
-   branding/configuration
-   notifications
-   audit information

Admin behavior should be permission/policy driven rather than scattered
`if (isAdmin)` checks.

> **Admin configuration belongs to an explicit policy/control layer.**

------------------------------------------------------------------------

## 4. Enterprise Feature-First Architecture

Preferred structure:

``` text
lib/
├── app.dart
├── config/
├── constants/
├── di/
├── router/
├── theme/
│
├── core/
│   ├── dialogs/
│   ├── errors/
│   ├── extensions/
│   ├── network/
│   ├── providers/
│   ├── services/
│   ├── storage/
│   ├── theme/
│   └── ...
│
└── features/
    ├── auth/
    ├── chat/
    └── ...
```

Reusable ECE capabilities belong in `core/`.

Product/domain functionality belongs in `features/`.

------------------------------------------------------------------------

## 5. Dependency Direction

Preferred flow:

``` text
UI
 ↓
Provider
 ↓
Repository / Service
 ↓
Data Source / Firebase / External Service
```

UI should not directly perform database operations when a
repository/service layer is appropriate.

------------------------------------------------------------------------

## 6. Single Responsibility

Every file, class, provider, service, repository, model, and widget
should have a clear responsibility.

Avoid giant files combining:

-   UI
-   database
-   permissions
-   networking
-   media processing
-   navigation
-   business rules

> **One responsibility per component unless combining responsibilities
> clearly improves the architecture.**

------------------------------------------------------------------------

## 7. Reuse Before Duplication

Before creating a new helper/service/widget/provider/repository:

1.  Search the project.
2.  Check whether an existing component can be reused.
3.  Extend it if appropriate.
4.  Create a new component only when the responsibility is genuinely
    different.

> **Reuse first. Duplicate only for a real architectural reason.**

------------------------------------------------------------------------

## 8. No Throwaway Architecture

Do not knowingly implement temporary architecture when the final
architecture is already understood.

For example, if a new message type should be a dedicated sealed subtype,
implement it directly as that subtype.

Avoid:

``` text
New Feature
 ↓
Legacy workaround
 ↓
Future migration
```

Prefer:

``` text
New Feature
 ↓
Correct dedicated architecture
```

`LocationMessage`, for example, should be a real message subtype rather
than being unnecessarily routed through `LegacyMessage`.

------------------------------------------------------------------------

## 9. Extensible Message Architecture

ECE messaging should evolve toward dedicated message types:

``` text
TextMessage
ImageMessage
VideoMessage
VoiceMessage
FileMessage
LocationMessage
SystemMessage
...
```

The message factory/parser must route known types to their correct
subtype.

Legacy support may remain where a genuine migration is required, but new
functionality should not unnecessarily depend on legacy structures.

------------------------------------------------------------------------

## 10. Feature Ownership

A feature should normally own its:

-   models
-   providers
-   repositories
-   services
-   screens
-   widgets

when those components are feature-specific.

Example:

``` text
core/location/
├── models/
├── providers/
├── repositories/
├── services/
├── screen/
└── widgets/
```

Move a component to shared `core/` only when it is genuinely reusable.

------------------------------------------------------------------------

## 11. UI / Business Logic Separation

UI focuses on:

-   layout
-   presentation
-   user interaction
-   navigation

Business/data logic belongs in appropriate:

-   providers
-   services
-   repositories
-   models

Avoid large business operations inside `build()`.

------------------------------------------------------------------------

## 12. Riverpod Provider Rules

Riverpod is the preferred state-management mechanism.

Providers should:

-   expose dependencies
-   manage state
-   connect UI to services/repositories
-   remain testable
-   avoid unnecessary UI knowledge

A provider is not a replacement for every service or repository.

------------------------------------------------------------------------

## 13. Repository Rules

Repositories abstract data access such as:

-   Firestore
-   Firebase Storage
-   Cloudinary
-   local storage
-   APIs
-   external data sources

UI should not need to know how the underlying data is stored.

------------------------------------------------------------------------

## 14. Service Rules

Services encapsulate focused operations that are not fundamentally
repository responsibilities.

Examples:

``` text
LocationService
LogoutService
ConnectivityService
MediaUploadService
NotificationService
```

Services should not become dumping grounds for unrelated logic.

------------------------------------------------------------------------

## 15. Theme / Design-System Rules

ECE must use a centralized design system.

Avoid scattering arbitrary colors through widgets.

Prefer:

``` text
AppColors
AppTextTheme
AppTheme
ThemeExtensions
semantic design tokens
```

Theme architecture should support:

-   Light
-   Dark
-   System
-   persistence
-   product customization
-   reusable component styling

> **Components consume design tokens; they do not invent their own
> design system.**

------------------------------------------------------------------------

## 16. No Hard-Coded Reusable Strings

Reusable, user-facing, configurable, or localization-sensitive strings
should have an appropriate centralized home.

Do not duplicate the same important text across unrelated files.

------------------------------------------------------------------------

## 17. Error Handling

Errors should be:

-   meaningful
-   user-friendly
-   logged where appropriate
-   separated from raw technical details

Use exception/error mapping where appropriate for Firebase and external
services.

------------------------------------------------------------------------

## 18. Security Rules

Security must never rely only on Flutter UI checks.

Use the appropriate combination of:

``` text
UI permission checks
+
Firestore Security Rules
+
Server-side validation where required
```

Hiding an admin button is not security.

> **Backend/data authorization is the security boundary.**

Private conversations must be protected at the data layer.

------------------------------------------------------------------------

## 19. Privacy / Least Privilege

Users should receive only data they are authorized to access.

Avoid unnecessarily exposing:

-   private messages
-   private media URLs
-   personal data
-   administrative information
-   internal identifiers

Do not log passwords, tokens, or unnecessary private content.

------------------------------------------------------------------------

## 20. Media Architecture

Media should be treated as first-class capabilities.

Examples:

``` text
Image
File
Voice
Video
Location
```

Where applicable, separate:

``` text
Draft
Sender
Upload
Message Model
Bubble
Preview
Viewer
```

Do not create one giant media class containing every media
responsibility.

------------------------------------------------------------------------

## 21. Message Sending Pipeline

Typical flow:

``` text
User Action
 ↓
Draft
 ↓
Preview / Validation
 ↓
Sender
 ↓
Repository
 ↓
Firestore
 ↓
Conversation Update
 ↓
UI Stream
```

The exact flow can vary, but responsibilities must remain clear.

------------------------------------------------------------------------

## 22. Conversation Preview

Every new message type must have an intentional conversation-list
preview.

Examples:

``` text
📷 Photo
🎥 Video
🎤 Voice message
📎 File
📍 Location
```

Do not accidentally use an empty text field as the preview of a non-text
message.

------------------------------------------------------------------------

## 23. Configuration Over Hard-Coding

Product-specific behavior should be configurable where appropriate.

Possible configuration:

``` text
ECE Configuration
├── Branding
├── Theme
├── Features
├── Permissions
├── Media
├── Messaging
├── Notifications
├── Moderation
└── Admin Policies
```

A product should be able to disable an unnecessary feature without
damaging unrelated features.

------------------------------------------------------------------------

## 24. Feature Flags

Feature flags may support:

-   gradual rollout
-   experiments
-   product-specific features
-   controlled releases
-   testing

Temporary flags should have a reason and, when appropriate, a removal
plan.

------------------------------------------------------------------------

## 25. Navigation

Major application routes should use the central router/navigation
architecture.

Local `MaterialPageRoute` navigation is acceptable for genuinely local
flows such as isolated previews when it keeps the design simpler.

Do not spread complex routing logic throughout widgets.

------------------------------------------------------------------------

## 26. Dependency Injection

Infrastructure dependencies should be created through providers/DI
mechanisms rather than repeatedly inside widgets.

Preferred:

``` text
Provider
 ↓
Service
 ↓
Repository
```

This improves:

-   testability
-   lifecycle management
-   reuse
-   maintainability

------------------------------------------------------------------------

## 27. Testing

Every meaningful feature needs a testing strategy.

Use appropriate levels:

``` text
Unit
 ↓
Service / Repository
 ↓
Provider
 ↓
Widget
 ↓
Integration / Device
```

Platform-sensitive functionality must be tested on real devices when
available, especially:

-   camera
-   microphone
-   location
-   notifications
-   file opening
-   media playback
-   permissions

Emulator success alone is not sufficient for platform-sensitive
features.

------------------------------------------------------------------------

## 28. Regression Testing

When fixing a bug:

1.  Reproduce it.
2.  Identify the root cause.
3.  Fix the root cause.
4.  Test the affected feature.
5.  Test related functionality.
6.  Record important findings in documentation.

Do not only patch the visible symptom when the architecture is the
actual problem.

------------------------------------------------------------------------

## 29. Incremental Development

ECE must be developed incrementally.

Preferred loop:

``` text
Understand
 ↓
Design
 ↓
Implement one meaningful step
 ↓
Run
 ↓
Test
 ↓
Verify
 ↓
Continue
```

> **One meaningful step at a time.**

Complex features should not be dumped as a complete codebase when
incremental implementation will improve understanding and debugging.

------------------------------------------------------------------------

## 30. Documentation Is Part of Engineering

ECE documentation must be maintained as part of development.

Core documents:

``` text
ECERules.md
ARCHITECTURE.md
CHANGELOG.md
GitHubRelease.md
PROJECT_STATE.md
ProjectRoot.md
ROADMAP.md
TESTING.md
TODO.md
VERSION_HISTORY.md
```

Additional documents may include:

``` text
SECURITY.md
CONTRIBUTING.md
MEDIA_ARCHITECTURE.md
FIREBASE_ARCHITECTURE.md
ADMIN_ARCHITECTURE.md
DESIGN_SYSTEM.md
API.md
DATABASE.md
DEPLOYMENT.md
```

------------------------------------------------------------------------

## 31. Documentation Responsibilities

  Document               Purpose
  ---------------------- --------------------------------------
  `ECERules.md`          Canonical engineering rules
  `ARCHITECTURE.md`      Current technical architecture
  `CHANGELOG.md`         Change history
  `GitHubRelease.md`     GitHub-ready release notes
  `PROJECT_STATE.md`     Current project condition
  `ProjectRoot.md`       Project structure/orientation
  `ROADMAP.md`           Future direction
  `TESTING.md`           Testing strategy/procedures
  `TODO.md`              Current actionable tasks
  `VERSION_HISTORY.md`   Version-by-version historical record

Do not use one document as a replacement for all the others.

------------------------------------------------------------------------

## 32. Documentation Update Rule

Important changes must update the appropriate documentation.

``` text
Architecture change
→ ARCHITECTURE.md

New release
→ CHANGELOG.md
→ VERSION_HISTORY.md
→ GitHubRelease.md

Current status
→ PROJECT_STATE.md

Future feature
→ ROADMAP.md

Testing change
→ TESTING.md

New task
→ TODO.md

Project structure change
→ ProjectRoot.md
```

------------------------------------------------------------------------

## 33. Versioning

Meaningful releases should have:

-   version number
-   date
-   feature/fix summary
-   testing status when appropriate
-   known limitations when relevant

Historical records should remain traceable and should not be rewritten
merely to look cleaner.

------------------------------------------------------------------------

## 34. Release Process

A release is not complete merely because the application compiles.

Preferred process:

``` text
Code
 ↓
Analyze
 ↓
Test
 ↓
Regression Test
 ↓
Documentation
 ↓
Version Update
 ↓
Release Notes
 ↓
Git Commit / Tag
```

------------------------------------------------------------------------

## 35. Dependency Rules

Do not upgrade packages merely because newer versions exist.

Before upgrading:

1.  Determine why.
2.  Check breaking changes.
3.  Check API/deprecation changes.
4.  Check transitive dependencies.
5.  Test affected features.
6.  Run analysis/tests.
7.  Update documentation if architecture/API behavior changes.

> **Dependency upgrades are engineering decisions, not rituals.**

Do not mix unrelated dependency upgrades into a feature implementation
without a reason.

------------------------------------------------------------------------

## 36. Deprecation Rules

When an API is deprecated:

1.  Understand the replacement.
2.  Confirm behavior compatibility.
3.  Migrate deliberately.
4.  Test the affected feature.
5.  Remove obsolete API usage.

------------------------------------------------------------------------

## 37. Firebase Rules

Firebase implementation should remain behind suitable repository/service
boundaries.

Firestore structure should be intentional and documented for important
domains.

Security-sensitive operations must be protected by Firestore Security
Rules.

------------------------------------------------------------------------

## 38. External Service Rules

External providers such as:

-   Firebase
-   Cloudinary
-   OpenStreetMap
-   mapping providers
-   notification providers
-   future APIs

should be isolated behind appropriate abstractions where practical.

ECE should remain capable of replacing a provider without rewriting
unrelated application layers.

------------------------------------------------------------------------

## 39. Performance Rules

Avoid unnecessary:

-   widget rebuilds
-   network requests
-   database reads
-   image decoding
-   media re-encoding
-   duplicate uploads
-   expensive work in `build()`

Use appropriate:

-   constraints
-   compression
-   thumbnails
-   lazy loading
-   caching

for media-heavy features.

------------------------------------------------------------------------

## 40. UI Stability

Asynchronous content must not cause avoidable layout jumps.

For network media:

-   use stable constraints
-   provide loading states
-   provide error states
-   consider eventual media dimensions
-   avoid replacing a small placeholder with an unexpectedly large
    layout

------------------------------------------------------------------------

## 41. Accessibility / UX

Consider:

-   readable text
-   touch targets
-   semantic labels
-   loading feedback
-   error feedback
-   disabled states
-   empty states
-   destructive-action confirmation
-   keyboard behavior
-   responsive layouts
-   light/dark themes

A feature is not finished merely because the underlying code works.

------------------------------------------------------------------------

## 42. Destructive Operations

Operations such as:

-   delete message
-   delete account
-   remove user
-   block user
-   revoke access
-   delete media

must have appropriate authorization and confirmation.

Clearly distinguish reversible and permanent actions.

------------------------------------------------------------------------

## 43. Admin Architecture

Admin functionality should have explicit concepts where appropriate:

``` text
Role
Permission
Policy
Admin Service
Admin Repository
Admin UI
```

Do not scatter administrative behavior through ordinary user features.

This becomes increasingly important as ECE supports multiple products.

------------------------------------------------------------------------

## 44. Product Layer vs ECE Core

Conceptually:

``` text
                 PRODUCT
                    │
          Product-specific features
                    │
                    ▼
               ECE CORE
                    │
       Reusable chat capabilities
                    │
                    ▼
          Infrastructure / Services
```

Example gaming product features:

``` text
Game rooms
Teams
Match chat
Voice lobby
Game invites
```

Example support product features:

``` text
Ticket chat
Agent assignment
Priority
SLA
Support queue
```

These should not unnecessarily contaminate reusable messaging core.

------------------------------------------------------------------------

## 45. Don't Over-Engineer

Do not create abstractions simply because abstraction is possible.

Create abstractions when they provide a real benefit:

-   reuse
-   testability
-   service replacement
-   clear ownership
-   customization
-   security boundary
-   architectural consistency

------------------------------------------------------------------------

## 46. Don't Under-Engineer

Do not put everything into:

``` text
message.dart
chat_screen.dart
utils.dart
helpers.dart
```

If a responsibility becomes a distinct domain, give it a proper
architectural home.

------------------------------------------------------------------------

## 47. File Size Guideline

There is no absolute line-count law.

As a practical signal:

> Around 300--400 lines means the design should be reviewed.

It does **not** mean every file over 400 lines must be split. Cohesion
and clarity matter more than an arbitrary number.

------------------------------------------------------------------------

## 48. Naming

Names should communicate responsibility.

Prefer:

``` text
location_service.dart
location_message_sender.dart
location_message.dart
location_message_bubble.dart
```

Avoid vague names such as:

``` text
helper.dart
manager.dart
misc.dart
common.dart
stuff.dart
```

unless the scope is genuinely clear.

------------------------------------------------------------------------

## 49. Comments

Comments should explain:

-   why something exists
-   architectural decisions
-   non-obvious behavior
-   platform limitations
-   security considerations

Avoid comments that merely restate the code.

------------------------------------------------------------------------

## 50. Architectural Decisions

For important architecture choices, record:

-   decision
-   reason
-   alternatives considered
-   consequence

This prevents repeated debates and preserves project knowledge.

------------------------------------------------------------------------

## 51. Bug-Fix Knowledge

Important bug fixes should preserve root-cause knowledge.

Example:

``` text
Problem:
Image bubble shifted chat layout.

Root cause:
Network image decoding changed layout after initial rendering.

Fix:
Stable constraints + controlled loading/error states.

Regression:
Tested image sending and scrolling again.
```

------------------------------------------------------------------------

## 52. No Silent Major Architecture Changes

When an implementation conflicts with existing architecture:

1.  Stop.
2.  Explain the conflict.
3.  Propose the clean solution.
4.  Agree on direction.
5.  Implement incrementally.

Do not silently introduce an architecture that contradicts ECE rules.

------------------------------------------------------------------------

## 53. Review Before Coding

For every non-trivial feature, answer:

1.  What is it?
2.  Who owns it?
3.  Is it reusable?
4.  Is it Core or Product-specific?
5.  What model is required?
6.  What repository/service is required?
7.  What provider is required?
8.  What UI is required?
9.  What security implications exist?
10. What documentation changes are required?
11. How will it be tested?

Then implement.

------------------------------------------------------------------------

## 54. Feature Completion Checklist

``` text
[ ] Architecture decided
[ ] Ownership decided
[ ] Model implemented
[ ] Repository/service implemented
[ ] Provider implemented
[ ] UI implemented
[ ] Error handling implemented
[ ] Loading state implemented
[ ] Empty state implemented where applicable
[ ] Security/permissions considered
[ ] Theme compatibility checked
[ ] Navigation checked
[ ] Device/platform behavior checked
[ ] Regression tested
[ ] Documentation updated
[ ] TODO/ROADMAP updated if necessary
[ ] Version history updated if released
```

------------------------------------------------------------------------

## 55. Git Rules

Prefer meaningful commits:

``` text
feat(location): add LocationMessage support
fix(media): stabilize image bubble layout
refactor(chat): separate message sender
docs(ece): update architecture rules
```

Avoid vague messages such as:

``` text
update
fix
changes
test
final
```

------------------------------------------------------------------------

## 56. GitHub Release Rules

GitHub releases should communicate:

-   version
-   major features
-   important fixes
-   breaking changes
-   testing status
-   known limitations when relevant

Release notes should be understandable without reading source code.

------------------------------------------------------------------------

## 57. Current Architecture Must Remain Understandable

A developer should be able to answer:

``` text
Where is this feature?
Who owns it?
Where does its state live?
Where is its business logic?
Where does its data come from?
How is it secured?
How is it tested?
How is it configured?
```

If these questions become difficult to answer, architecture review is
required.

------------------------------------------------------------------------

# 58. ECE Golden Rules

### Golden Rule 1

**ECE is an engine, not a clone.**

### Golden Rule 2

**Build reusable capabilities before product-specific behavior.**

### Golden Rule 3

**Reuse before duplication.**

### Golden Rule 4

**Do not knowingly write throwaway architecture.**

### Golden Rule 5

**One responsibility per component.**

### Golden Rule 6

**UI, Provider, Repository, Service, and Data layers have different
responsibilities.**

### Golden Rule 7

**Security must be enforced at the backend/data boundary, not only in
the UI.**

### Golden Rule 8

**Admin control must be explicit and permission-driven.**

### Golden Rule 9

**Product-specific behavior must not unnecessarily contaminate ECE
Core.**

### Golden Rule 10

**Documentation is part of implementation.**

### Golden Rule 11

**Test real devices for platform-sensitive functionality.**

### Golden Rule 12

**Develop incrementally: understand → design → implement → test →
verify.**

### Golden Rule 13

**Do not upgrade dependencies without a reason.**

### Golden Rule 14

**Fix root causes, not only symptoms.**

### Golden Rule 15

**When architecture is unclear, design before coding.**

------------------------------------------------------------------------

# 59. ECE Development Loop

``` text
                 ┌──────────────┐
                 │ REQUIREMENT  │
                 └──────┬───────┘
                        ↓
                 ┌──────────────┐
                 │    DESIGN    │
                 └──────┬───────┘
                        ↓
                 ┌──────────────┐
                 │  IMPLEMENT   │
                 └──────┬───────┘
                        ↓
                 ┌──────────────┐
                 │     TEST     │
                 └──────┬───────┘
                        ↓
                 ┌──────────────┐
                 │    VERIFY    │
                 └──────┬───────┘
                        ↓
                 ┌──────────────┐
                 │  DOCUMENT    │
                 └──────┬───────┘
                        ↓
                 ┌──────────────┐
                 │   RELEASE    │
                 └──────┬───────┘
                        │
                        └────────────→ Next Feature
```

------------------------------------------------------------------------

# 60. Final ECE Rule

> **Every line of ECE code should move us toward a reusable, secure,
> maintainable, customizable Enterprise Chat Engine---not merely toward
> a working demo.**

If a shortcut makes today's feature easier but makes tomorrow's ECE
product harder to build, the shortcut should normally be rejected.

------------------------------------------------------------------------

**End of ECERules.md**
