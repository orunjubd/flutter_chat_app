chat_app/

lib/
android/
ios/

README.md
CHANGELOG.md
ROADMAP.md
ARCHITECTURE.md
TESTING.md
TODO.md
GitHubRelease.md
LICENSE

pubspec.yaml
============================================
# chat_app — Project Root Index

A Flutter/Firebase chat application with rich media messaging
(text, image, document, voice, video, location, and — in progress —
contact sharing).

## Where to look

| Document | Purpose |
|---|---|
| `README.md` | Setup, dependencies, and running the app |
| `ARCHITECTURE.md` | How the current feature (Location, v1.7.2) is layered and why |
| `ROADMAP.md` | Full phase list, past and planned |
| `PROJECT_STATE.md` | What's done, what's in progress, known open items |
| `CHANGELOG.md` | Version-by-version change history |
| `VERSION_HISTORY.md` | High-level version timeline |
| `GitHubRelease.md` | Draft release notes for the current version |

## Current version

**v1.7.2** — Phase 4.7 (Location Messages) complete.
Phase 4.9 (Contact Messages) starting next.

## Core design principle this project follows

Each message type owns its own model, service, and (where relevant)
sender/repository logic — no type's fields are bolted onto a shared
model unless the field is genuinely universal across every type (e.g.
`id`, `senderId`, `createdAt` on the base `Message` class). Video,
Location, and (in progress) Contact were each built from the start as
independent sealed `Message` subtypes for exactly this reason. Image,
voice, and document currently remain on a shared flat legacy shape for
backward-compatibility reasons with existing production data, and are
planned to be migrated the same way, one type at a time.
