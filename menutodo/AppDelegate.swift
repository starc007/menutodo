import AppKit
import SwiftUI
import Observation

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var panel: NSPanel?
    private var eventMonitor: Any?
    let store = TodoStore()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            let img = NSImage(systemSymbolName: "checklist", accessibilityDescription: "MenuTodo")
            img?.isTemplate = true
            button.image = img
            button.imagePosition = .imageLeft
            button.action = #selector(togglePanel)
            button.target = self
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 400),
            styleMask: [.fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.isFloatingPanel = true
        panel.level = .popUpMenu
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentView = NSHostingView(rootView: PopoverView(store: store))
        self.panel = panel

        eventMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { [weak self] _ in
            self?.closePanel()
        }

        observeBadge()
        updateBadge()
    }

    @objc private func togglePanel() {
        if panel?.isVisible == true {
            closePanel()
        } else {
            openPanel()
        }
    }

    private func openPanel() {
        guard let button = statusItem?.button,
              let buttonWindow = button.window else { return }

        let buttonFrame = buttonWindow.convertToScreen(
            button.convert(button.bounds, to: nil)
        )
        let x = buttonFrame.midX - 160
        let y = buttonFrame.minY - 400 - 6
        panel?.setFrame(NSRect(x: x, y: y, width: 320, height: 400), display: true)
        panel?.makeKeyAndOrderFront(nil)
        if #available(macOS 14, *) {
            NSApp.activate()
        } else {
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func closePanel() {
        panel?.orderOut(nil)
    }

    private func updateBadge() {
        let count = store.pendingCount
        statusItem?.button?.title = count > 0 ? " \(count)" : ""
    }

    private func observeBadge() {
        withObservationTracking {
            _ = store.pendingCount
        } onChange: { [weak self] in
            DispatchQueue.main.async {
                self?.updateBadge()
                self?.observeBadge()
            }
        }
    }
}
