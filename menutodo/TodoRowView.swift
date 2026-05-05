import SwiftUI

struct TodoRowView: View {
    let item: TodoItem
    let store: TodoStore
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 10) {
            Button {
                store.toggle(item)
            } label: {
                Image(systemName: item.done ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.done ? Color.green : Color.secondary)
                    .font(.system(size: 16))
            }
            .buttonStyle(.plain)

            Text(item.text)
                .strikethrough(item.done)
                .foregroundStyle(item.done ? Color.secondary : Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                store.delete(item)
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(Color.secondary)
                    .font(.system(size: 11))
            }
            .buttonStyle(.plain)
            .opacity(isHovered ? 1 : 0)
        }
        .contentShape(Rectangle())
        .padding(.vertical, 2)
        .onHover { isHovered = $0 }
    }
}
