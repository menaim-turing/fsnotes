# Signing & Capabilities Setup

This guide explains the provisioning/signing fixes and how to restore full capabilities when you're ready.

## What Was Fixed

### 1. FSNotes iOS UITests – Code Signing
- Added `DEVELOPMENT_TEAM = 9827F3T388` and `CODE_SIGN_IDENTITY = "iPhone Developer"`
- **If you use a different Apple Developer account:** In Xcode, select the **FSNotes iOS UITests** target → **Signing & Capabilities** → **Team** → choose your team.

### 2. FSNotes iOS & Share Extension – Development Capabilities
- **Development entitlements** (no App Group, iCloud, Push) are used so the project can build without them:
  - `FSNotes iOS/FSNotes iOS Development.entitlements`
  - `FSNotes iOS Share/FSNotes iOS Share Development.entitlements`
- **Capabilities disabled** in the project: App Groups, iCloud, Push Notifications, Background Modes.

**Result:** The app builds and runs in the simulator, but:
- No iCloud sync
- No push notifications
- Share Extension’s “last project/tags” memory is not shared with the main app (falls back to default)

---

## Restoring Full Capabilities

When you want full functionality (iCloud, App Group, Push):

### Step 1: Register in Apple Developer Portal

1. Go to [developer.apple.com](https://developer.apple.com) → **Certificates, Identifiers & Profiles → Identifiers**
2. **App Groups:** Create `group.es.fsnot.user.defaults` (or your own, e.g. `group.com.yourname.fsnotes`)
3. **iCloud Container:** Create `iCloud.co.fluder.fsnotes` (or your own, e.g. `iCloud.com.yourname.fsnotes)
4. **App IDs:** Add App Groups and iCloud capabilities to your app’s App ID.

### Step 2: Enable Capabilities in Xcode

1. Select **FSNotes iOS** target → **Signing & Capabilities** → **+ Capability**
2. Add: **App Groups**, **iCloud**, **Push Notifications**
3. Add the App Group identifier and iCloud container.

### Step 3: Switch Back to Full Entitlements

In `FSNotes.xcodeproj/project.pbxproj` (or via Xcode):

- **FSNotes iOS:** Set `CODE_SIGN_ENTITLEMENTS = "FSNotes iOS/FSNotes iOS.entitlements"`
- **FSNotes iOS Share Extension:** Set `CODE_SIGN_ENTITLEMENTS = "FSNotes iOS Share/FSNotes iOS Share.entitlements"`

### Step 4: Change Team (if needed)

If you use a different team than `9827F3T388` and `866P6MTE92`:

- In Xcode: **Signing & Capabilities** → **Team** → choose your team.

---

## If You Use a Different App Group

If you register a new App Group (e.g. `group.com.yourname.fsnotes`), update these files:

- `FSNotes iOS/FSNotes iOS.entitlements`
- `FSNotes iOS Share/FSNotes iOS Share.entitlements`
- `FSNotes iOS/Extensions/UserDefaultsManagement+.swift` – `suiteName:`
- `FSNotesCore/UserDefaultsManagement.swift` – `suiteName:`
- `FSNotes iOS/Helpers/SandboxBookmark.swift` – `suiteName:`
