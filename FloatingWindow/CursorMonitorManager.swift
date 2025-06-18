//
//  CursorMonitorManager.swift
//  Stefan
//
//  Created by Kamil Andrusz on 18/06/2024.
//

import SwiftUI
import os

class CursorMonitorManager: NSObject, ObservableObject {
    private weak var window: NSWindow?
    private var globalEventMonitor: Any?
    private var localEventMonitor: Any?
    private var lastDisplay: NSScreen?
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "CursorMonitorManager")

    init(window: NSWindow) {
        self.window = window
        super.init()
    }

    func startMonitoring() {
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
            self?.handleMouseEvent(event)
        }

        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
            self?.handleMouseEvent(event)
            return event
        }

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(activeSpaceDidChange),
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil
        )
        logger.debug("CursorMonitorManager started")
        updateWindowPosition()
    }

    func stopMonitoring() {
        if let monitor = globalEventMonitor {
            NSEvent.removeMonitor(monitor)
        }

        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
        }

        NSWorkspace.shared.notificationCenter.removeObserver(self)
        logger.debug("CursorMonitorManager stopped")
    }

    private func handleMouseEvent(_ event: NSEvent) {
        // updateWindowPosition()
        checkCursorPosition()
    }
    
    func cursorDidMoveToNewDisplay(_ display: NSScreen) {
        logger.debug("Cursor moved to new display: \(display.localizedName)")
        guard let window = self.window else { return }
        repositionWindow(window: window, to: display)
    }

    func repositionWindow(window: NSWindow, to newScreen: NSScreen) {
        let oldScreen = window.screen ?? NSScreen.main!
        let oldFrame = window.frame
        let newFrame = newScreen.visibleFrame

        let xRatio = (oldFrame.origin.x - oldScreen.visibleFrame.minX) / oldScreen.visibleFrame.width
        let yRatio = (oldFrame.origin.y - oldScreen.visibleFrame.minY) / oldScreen.visibleFrame.height

        var newX: CGFloat
        var newY: CGFloat

        if xRatio < 0.25 {
            newX = newFrame.minX + (oldFrame.origin.x - oldScreen.visibleFrame.minX)
        } else if (xRatio > 0.75) {
            newX = newFrame.maxX - (oldScreen.visibleFrame.maxX - oldFrame.origin.x)
        } else {
            newX = newFrame.minX + xRatio * newFrame.width
        }

        if yRatio < 0.20 {
            newY = newFrame.minY + (oldFrame.origin.y - oldScreen.visibleFrame.minY)
        } else if (yRatio > 0.80) {
            newY = newFrame.maxY - (oldScreen.visibleFrame.maxY - oldFrame.origin.y)
        } else {
            newY = newFrame.minY + yRatio * newFrame.height
        }

        let newOrigin = CGPoint(x: newX, y: newY)
        let newSize = oldFrame.size
        let newWindowFrame = CGRect(origin: newOrigin, size: newSize)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            window.animator().setFrame(newWindowFrame, display: true)
        }
    }

    func updateWindowPosition() {
        guard let window = self.window else { return }
        let mouseLocation = NSEvent.mouseLocation
        let windowSize = window.frame.size

        let newX = mouseLocation.x + windowSize.width / 2
        let newY = mouseLocation.y + windowSize.height / 2

        let newOrigin = CGPoint(x: newX, y: newY)
        window.setFrameOrigin(newOrigin)
    }

    @objc private func activeSpaceDidChange() {
        logger.debug("Active space did change.")
        guard let window = self.window, let currentDisplay = NSScreen.mainScreenContainingCursor else { return }
        repositionWindow(window: window, to: currentDisplay)
//        updateWindowPosition()
    }

    @objc private func checkCursorPosition() {
        guard let currentDisplay = NSScreen.mainScreenContainingCursor else { return }
        if currentDisplay != lastDisplay {
            lastDisplay = currentDisplay
            cursorDidMoveToNewDisplay(currentDisplay)
        }
    }
}

extension NSScreen {
    static var mainScreenContainingCursor: NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        return screens.first { NSMouseInRect(mouseLocation, $0.frame, false) }
    }
}
