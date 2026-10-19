# ECE Chat: Implemented Features (Phases 4 to 6)

## Phase 4: Media / Calls
- 1:1 voice and video calls over LiveKit, Firestore signaling (`calls/{id}`)
- Hybrid incoming UI: own ringtone and card in foreground, native CallKit in background/killed
- Calling / Ringing / Busy labels, ring timeout (30 s), call history, call lines in chat
- Group voice and video calls (min 3, max 8 video / 16 voice), ring timeout, joinable banner,
  group call history tab, last participant standing ends the call
- Calls started from a group chat; a group of two calls 1:1
- Push for background and killed states through the dev relay
- CallController split into CallRoomEventsBinder, CallKitCallbacks, CallAppLifecycleHandler

## Phase 5: Conversations
- Search conversations (name, last message) with recent searches
- Pin (max 3), archive, favorite, mute (8 h / 1 week / always), per-user settings
- Filters: All, Unread, Favorites, Groups
- Delete chat for me (removedFor), history hidden after delete (clearedAt)

## Phase 6: Group Chat
- Create group (name max 25, members, "members can send")
- Group info, member list, add/remove, promote/demote, per-member permissions
  (send, addMembers, deleteMessages, editInfo); creator protected from other admins
- Last admin leaving promotes the longest-standing member
- Group avatar upload, system messages in the same transaction as membership changes
- Read-only mode, sender names with stable colours, typing for several people
- New members see only messages from their join time
- Read-only profile screen; email and phone in `users/{uid}/private/*` with opt-in sharing
- Message edit (own text, 15 minutes), delete for me / for everyone
- Account deletion with tombstone profile ("Deleted account")

## Security and infrastructure
- Staged Firestore rules (`firestore.rules`), contact privacy migration on login
- `push_relay/cleanup.js` (dry-run by default), dev push relay (`relay.js`)