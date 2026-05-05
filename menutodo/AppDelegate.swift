import AppKit
import SwiftUI
import Observation

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    let store = TodoStore()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "checklist", accessibilityDescription: "MenuTodo")
            button.action = #selector(togglePopover)
            button.target = self
        }

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: PopoverView(store: store))
        self.popover = popover

        observeBadge()
        updateBadge()
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }
        if popover?.isShown == true {
            popover?.performClose(nil)
        } else {
            if #available(macOS 14, *) {
                NSApp.activate()
            } else {
                NSApp.activate(ignoringOtherApps: true)
            }
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
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
