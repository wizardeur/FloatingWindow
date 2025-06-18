# FloatingWindow

FloatingWindow is a minimal macOS example app demonstrating how to create a floating window that can join any space (virtual desktop) on macOS. The window remains visible across all spaces and follows the cursor between multiple displays.

## Features

- **Floating Window**: The window uses `.floating` level and `.canJoinAllSpaces` collection behavior, so it appears above most other apps and on every virtual desktop (space).
- **Transparent, Borderless UI**: The window is borderless, transparent, and can be moved by dragging its background.
- **Follows Cursor Across Displays**: When your mouse moves to a different screen, the window jumps to the corresponding display, maintaining its position relative to the display.
- **Simple SwiftUI Content**: The window displays a simple label on a colored background as a demonstration.

## How it Works

- The app sets up a custom `NSWindow`:
  - `styleMask: [.borderless, .fullSizeContentView]`
  - `window.level = .floating`
  - `window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]`
  - Transparent background, no title bar or buttons.
- A `CursorMonitorManager` observes mouse and space change events:
  - When the cursor moves to a new display, the window is repositioned to that display.
  - The window can be moved by dragging.

## Example Code Snippet

```swift
window = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: 200, height: 200),
    styleMask: [.borderless, .fullSizeContentView],
    backing: .buffered,
    defer: false)
window.isOpaque = false
window.backgroundColor = .clear
window.level = .floating
window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
window.contentView = NSHostingView(rootView: contentView)
window.isMovableByWindowBackground = true
```

## Requirements

- macOS 12.0+
- Xcode 13+
- Swift
- **App must be set as an Agent (UIElement):**
  To allow the floating window to behave as intended (e.g., no Dock icon, no menu bar), set the application to be an Agent in your `Info.plist`.  
  Add the following key-value pair:
  ```xml
  <key>LSUIElement</key>
  <true/>
  ```
  This ensures the app runs as a background (Agent) application.

## Running the App

1. Clone this repository.
2. Open `FloatingWindow.xcodeproj` in Xcode.
3. Build and run the app.

You should see a small floating window labeled "Floating Window" that stays above other windows and follows your mouse between displays and spaces.

## License

This project is provided as-is for educational purposes.

---

**Author**: [wizardeur](https://github.com/wizardeur)
