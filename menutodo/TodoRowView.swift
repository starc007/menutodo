import SwiftUI

struct TodoRowView: View {
    let item: TodoItem
    let store: TodoStore
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 10) {
            Button { store.toggle(item) } label: {
                Image(systemName: item.done ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.done ? Color.green : Color.secondary)
                    .font(.system(size: 15))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.text)
                    .strikethrough(item.done)
                    .foregroundStyle(item.done ? Color.secondary : Color.primary)
                    .font(.system(size: 13))
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let tag = item.tag {
                    Text(tag)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.accentColor.opacity(0.9))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.12), in: Capsule())
                }
            }

            Button { store.delete(item) } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(Color.secondary)
                    .font(.system(size: 10, weight: .medium))
            }
            .buttonStyle(.plain)
            .opacity(isHovered ? 1 : 0)
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .background(
            isHovered ? Color.primary.opacity(0.04) : Color.clear,
            in: RoundedRectangle(cornerRadius: 6)
        )
    }
}
