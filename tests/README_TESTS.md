# FSNotes iOS Unit Tests – "Choose Project & Tags" Feature

## Setup

1. **Add the test target in Xcode:**
   - File → New → Target
   - Choose **iOS** → **Unit Testing Bundle**
   - Click **Next**
   - Product Name: `FSNotes iOSTests`
   - Target to be tested: `FSNotes iOS`
   - Click **Finish**

2. **Add test files to the target:**
   - In the Project navigator, select the `tests` folder
   - Right-click `ShareTagNormalizerTests.swift` → Add Files to "FSNotes"...
   - Ensure the target **FSNotes iOSTests** is checked
   - Repeat for `ShareProjectSelectionTests.swift`

3. **Run tests:**
   - Press `⌘U` or Product → Test
   - Or run: `xcodebuild test -workspace FSNotes.xcworkspace -scheme "FSNotes iOS" -destination 'platform=iOS Simulator,name=iPhone 16'`

## Test Files

| File | Purpose |
|------|---------|
| `ShareTagNormalizerTests.swift` | Tests tag parsing and formatting (`normalizedTags`, `formatTagsForContent`) |
| `ShareProjectSelectionTests.swift` | Tests tag format for note content |

## Tested Logic

- **ShareTagNormalizer.normalizedTags(from:)** – Parses tag input (e.g. `"work, urgent"`, `"#tag1 tag2"`) into normalized tags
- **ShareTagNormalizer.formatTagsForContent(_:)** – Formats tags for note content (e.g. `["work", "urgent"]` → `"#work #urgent"`)
