import AppKit
import SwiftUI
import Observation

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    let store = TodoStore()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = badgeImage(count: 0)
            button.imageScaling = .scaleProportionallyDown
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
        statusItem?.button?.image = badgeImage(count: store.pendingCount)
    }

    private func badgeImage(count: Int) -> NSImage {
        let size = NSSize(width: 20, height: 16)
        let image = NSImage(size: size, flipped: false) { _ in
            let cfg = NSImage.SymbolConfiguration(pointSize: 13, weight: .regular)
            if let icon = NSImage(systemSymbolName: "checklist", accessibilityDescription: nil)?
                    .withSymbolConfiguration(cfg) {
                icon.draw(in: NSRect(x: 0, y: 1, width: 13, height: 13))
            }
            if count > 0 {
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: NSFont.monospacedDigitSystemFont(ofSize: 9, weight: .semibold),
                    .foregroundColor: NSColor.labelColor
                ]
                NSAttributedString(string: "\(count)", attributes: attrs)
                    .draw(at: NSPoint(x: 14, y: 5))
            }
            return true
        }
        image.isTemplate = false
        return image
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
