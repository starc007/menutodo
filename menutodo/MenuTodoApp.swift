import SwiftUI

@main
struct MenuTodoApp: App {
    @State private var store = TodoStore()

    var body: some Scene {
        MenuBarExtra {
            PopoverView(store: store)
        } label: {
            HStack(spacing: 3) {
                Image(systemName: "checkmark.circle.fill")
                if store.pendingCount > 0 {
                    Text("\(store.pendingCount)")
                        .font(.caption2.monospacedDigit().weight(.semibold))
                }
            }
        }
        .menuBarExtraStyle(.window)
    }
}
