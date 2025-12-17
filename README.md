# PinDrop Chat (Firestore + Cubit + MVVM + E2EE)

A minimal Flutter (3.38+) group chat app:
- Username setup
- Create room (shows roomId + PIN)
- Join room (roomId + PIN)
- Real-time group messaging with Firestore
- End-to-End Encryption using shared PIN (PIN is never stored remotely)
- Users only see messages created AFTER they joined the room

## Tech
- Flutter 3.38+
- Firebase: Auth (anonymous), Firestore
- flutter_bloc (Cubit) for state management
- MVVM layering (Views + ViewModels/Cubits + Repositories + Services)
- cryptography package (AES-GCM + PBKDF2)

## Firestore Model
rooms/{roomId}
  - name
  - createdAt
  - createdBy
  - saltB64 (public)

rooms/{roomId}/members/{uid}
  - uid
  - username
  - joinedAt
  - lastSeenAt

rooms/{roomId}/messages/{messageId}
  - senderId
  - senderName
  - createdAt
  - cipherB64
  - ivB64
  - version

## How encryption works
1. Creator generates:
   - PIN (6 digits) -> shared outside the app
   - SALT (16 bytes random) -> stored in room doc as `saltB64` (NOT secret)
2. On join:
   - App fetches room salt from Firestore
   - Derives 256-bit key using PBKDF2(pin, salt, 120k iterations)
3. Sending message:
   - Encrypt locally with AES-GCM
   - Store only encrypted payload: cipherB64 + ivB64
4. Receiving message:
   - Decrypt locally with derived key
   - If PIN is wrong => AES-GCM auth fails => UI shows "Unable to decrypt message"

✅ PIN is never stored remotely.

## Message visibility after join
When a user joins a room, we store `members/{uid}.joinedAt` (serverTimestamp).
Message stream query:
- `createdAt >= joinedAt`
So the user cannot see messages from before they joined.

## Setup
1. Create Firebase project
2. Add Android + iOS apps
3. Run:
   - `flutterfire configure`
4. Ensure Firestore + Anonymous Auth enabled

## Firestore Security Rules (baseline)
- Allow read/write in rooms if user is authenticated and is a member
- Do NOT store PIN in rules or database

## Run
flutter pub get
flutter run
