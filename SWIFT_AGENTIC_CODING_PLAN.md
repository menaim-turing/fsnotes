# Swift Agentic Coding – Professional Plan for FSNotes Project

Based on the **Penguin Swift Coding Guideline** and **Swift Agentic Coding One-Pager**, this document outlines what you should do for your Turing Xcode agent training project with FSNotes.

---

## Part 1: What You Should Do (Action Plan)

### 1. **Align with the Vibe Coding Trajectories Framework**

Your project fits the **"Vibe Coding" Trajectories** adjacency (Adjacency 4 in the One-Pager):

- **What it is:** Real developer-in-the-loop agent trajectories while building/modifying iOS apps in Xcode
- **Your role:** Produce and evaluate trajectory samples for the dataset
- **Key principle:** Capture failure modes and recovery, not just success cases

### 2. **Deliverables Checklist (Per Sample)**

| # | Deliverable | Status |
|---|-------------|--------|
| 1 | Clone/use real SwiftUI repo (FSNotes ✓) | Done |
| 2 | Design a feature prompt (Choose Project & Tags ✓) | Done |
| 3 | One complete trajectory sample | In progress |
| 4 | Structured documentation (modeled after Trainer Workflow Guideline) | To do |
| 5 | Patch or PR-style diff of agent-produced changes | To do |
| 6 | Rubric used for evaluation | To do |
| 7 | Evidence of verification (logs, screenshots, test output) | To do |
| 8 | Capture trajectory (via xcode-claude-inspector) | To do |
| 9 | Implement Unit Tests / UI Tests / Snapshot / Functionality Test | In progress |
| 10 | Write working solution that passes all tests | To do |

### 3. **Malti's Task as Reference (Professional Approach)**

Malti's task (BookPlayer – Synchronized Text Viewer) is the gold standard. Key takeaways:

- **Problem understanding:** Explicit LRCParserError handling, default state for no transcript, correct icon placement
- **Project alignment:** MVVM, AVFoundation, SwiftUI embedded in UIKit, mirrored singletons (LRCService like ArtworkService)
- **Correctness:** Parser metadata, auto-scroll sync, z-index fixes, view model state routing
- **UX:** Flip animations, native UIDocumentPickerViewController, scoped resource access
- **Build & Test:** 5 consecutive clean builds, no regressions, no permission crashes
- **Code quality:** Segregated responsibilities, Combine observers isolated, `@Published` and `Result` paradigms
- **Convergence:** Todo-list across 9 checkpoints, layered features iteratively, production-ready

**Apply to your FSNotes feature:** Document each decision (UserDefaults app group, configuration items, tag parsing) in the same structured way.

### 4. **Trajectory Documentation Steps**

1. **Before starting:** Commit initial state; record commit SHA
2. **During run:** Commit every turn separately
3. **Use xcode-claude-inspector:**
   - Run `xcode-claude-inspector.command` before opening project
   - Execute prompt with agent
   - After run, open `output/parsed/` and map TOOL_USE + chain of thought to Trajectory Form
4. **Per turn, document:**
   - Prompt sequence
   - Agent output sequence
   - Action type (Planning / Edit / Build / Test / Fix / Preview)
   - Result (Correct / Incorrect / Partial)
   - Files touched
   - Build status (Pass / Fail / N/A)
   - Failure analysis (if any): type, why it failed, recovery

### 5. **Rubric Dimensions (Score 0–3, Lower = Better)**

| Dimension | 0 (Perfect) | 1 (Minor) | 2 (Severe) | 3 (Unacceptable) |
|-----------|-------------|-----------|------------|------------------|
| Functional Correctness | All acceptance criteria met | Redundant logic, minor layout issues | Misses edge case | Hallucination, ignores prompt |
| Swift Idioms & UI | Modern Swift, correct state | Slightly outdated syntax | Heavy sync on main thread | Force-unwrap, crashes |
| Build Stability | Clean, no warnings | 1–2 trivial warnings | Barely compiles | Target broken |

### 6. **Verification Requirements**

- **Unit tests:** Run target tests; verify `post_agent_log.txt` matches `xcodebuild test`
- **UI / Snapshot:** If SwiftUI/UIKit touched, verify via Snapshot tests, Xcode Previews, or manual Simulator
- **Share Extension:** Manual testing required (see Part 2 below)

### 7. **Environment & Tools**

- macOS required (iOS apps cannot run on Linux)
- Xcode 26.3 with agentic coding support
- Default agent configs (Codex or Claude) – do not customize skills
- Use `xcode-claude-inspector` for trajectory logs

---

## Part 2: Manual Testing – Choose Project & Tags When Sharing

### Prerequisites

- FSNotes iOS app installed on device or simulator
- At least one non-default project (create via Settings → Projects if needed)
- App Group `group.es.fsnot.user.defaults` configured for main app and Share Extension

### Test 1: Share URL with Project Selection

1. Open **Safari** and navigate to any webpage (e.g. `https://apple.com`)
2. Tap **Share** → select **FSNotes**
3. In the share sheet, tap the **Project** row
4. Verify an action sheet appears with all non-trash projects
5. Select a project (e.g. "Work" or "Personal")
6. Verify the Project row shows the selected project name
7. Tap **New note** (or Post)
8. Open FSNotes and verify the note appears in the selected project
9. Share again; verify the last project is pre-selected

### Test 2: Share URL with Tags

1. Share a URL to FSNotes
2. Tap the **Tags** row
3. Enter tags: `work, ideas, inbox`
4. Tap **Save**
5. Tap **New note**
6. Open FSNotes, find the note, and verify it has tags `#work`, `#ideas`, `#inbox`
7. Share again; verify the Tags field is pre-filled with `work, ideas, inbox`

### Test 3: Share Image

1. Open **Photos** and select an image
2. Tap **Share** → **FSNotes**
3. Select a project and optionally add tags
4. Tap **New note**
5. Verify the note appears in the selected project with the image and tags

### Test 4: Share Plain Text

1. Copy text from any app (e.g. Notes)
2. Tap **Share** → **FSNotes**
3. Select project and tags
4. Tap **New note**
5. Verify the note appears in the correct project with the correct tags

### Test 5: No Projects Exist

1. If possible, temporarily remove or hide all projects except default
2. Share to FSNotes
3. Tap **Project** row
4. Verify a friendly message: "No projects found. Notes will be saved in the default location."
5. Verify no crash; note saves to default project

### Test 6: Persistence (Last Used)

1. Share a URL, select project "A", add tags "tag1, tag2", save
2. Share another URL (e.g. from Safari)
3. Verify Project and Tags rows show "A" and "tag1, tag2" without re-entering

---

## Part 3: UI Tests (Implementation)

UI tests are implemented in `FSNotes iOS UITests/FSNotes_iOS_UITests.swift`. The **FSNotes iOS UITests** target is added to the Xcode project.

### What the UI Tests Cover

- **testAppLaunches** – App launches without crashing
- **testAppDisplaysMainInterface** – Main interface (notes table or loading state) appears
- **testNavigationBarExists** – Navigation bar is visible
- **testNotesTableViewAccessible** – Notes list table is accessible
- **testNotesListShowsContent** – Notes list displays content when notes exist
- **testSearchBarAccessible** – Search functionality is reachable
- **testAppCanNavigate** – App can navigate (e.g. More menu)

### How to Run UI Tests

1. Open the project in Xcode
2. Select the **FSNotes iOS** scheme
3. Choose an iOS Simulator (e.g. iPhone 16)
4. Press **⌘U** to run all tests, or use **Product → Test**

### Command Line

```bash
xcodebuild -scheme "FSNotes iOS" -destination 'platform=iOS Simulator,name=iPhone 16' test
```

(Replace `iPhone 16` with an available simulator from `xcrun simctl list devices`)

### Important Note

**Share Extension UI cannot be tested via XCUITest** – it runs in a separate process when the user shares from Safari, Photos, etc. The Share Extension (Choose Project & Tags) is verified via **manual testing** (Part 2 above).

---

## Part 4: Summary

| Action | Priority |
|--------|----------|
| Complete trajectory documentation | High |
| Run xcode-claude-inspector for your agent run | High |
| Fill Trajectory Form & Rubric | High |
| Add UI tests | Medium |
| Manual verification of Share feature | High |
| PR with evidence + spreadsheet link | Final |

---

*Reference: Penguin Swift Agentic Coding Guideline, Swift Agentic Coding One-Pager, Malti's Task (BookPlayer).*
