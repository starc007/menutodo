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
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = badgeImage(count: 0)
            button.imageScaling = .scaleProportionallyDown
            button.action = #selector(togglePanel)
            button.target = self
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 400),
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
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
