import SwiftUI
@main
struct FloatingWindowApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var cursorMonitorManager: CursorMonitorManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = ContentView()
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
        window.center()
        window.setFrameAutosaveName("FloatingWindow")
        window.makeKeyAndOrderFront(nil)
        window.isReleasedWhenClosed = false
        window.orderFrontRegardless()
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.isMovableByWindowBackground = true

        self.cursorMonitorManager = CursorMonitorManager(window: window)
        self.cursorMonitorManager?.startMonitoring()

        DispatchQueue.main.async {
            self.cursorMonitorManager?.updateWindowPosition()
        }
    }

    deinit {
        cursorMonitorManager?.stopMonitoring()
    }
}

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.clear

            Text("Floating Window")
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.yellow.opacity(0.8))
                        .shadow(radius: 10)
                )
        }
        .frame(width: 200, height: 200)
    }
}
