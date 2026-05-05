import SwiftUI

struct PopoverView: View {
    let store: TodoStore
    @State private var newText = ""
    @State private var newTag = ""
    @State private var selectedTag: String? = nil
    @State private var showTagPicker = false
    @FocusState private var inputFocused: Bool

    private var filteredTodos: [TodoItem] {
        guard let tag = selectedTag else { return store.todos }
        return store.todos.filter { $0.tag == tag }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            if !store.allTags.isEmpty {
                tagBar
            }
            Divider().opacity(0.3)
            todoList
            Divider().opacity(0.3)
            addInput
        }
        .frame(width: 320, height: 420)
        .modifier(GlassModifier())
    }

    // MARK: Header

    private var header: some View {
        HStack {
            Text("Todos")
                .font(.system(size: 15, weight: .semibold))
            Spacer()
            if store.todos.contains(where: { $0.done }) {
                Button("Clear done") { store.clearCompleted() }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 10)
    }

    // MARK: Tag bar

    private var tagBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                TagChip(label: "All", selected: selectedTag == nil) {
                    selectedTag = nil
                }
                ForEach(store.allTags, id: \.self) { tag in
                    TagChip(label: tag, selected: selectedTag == tag) {
                        selectedTag = (selectedTag == tag) ? nil : tag
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
        }
    }

    // MARK: List

    private var todoList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredTodos) { item in
                    TodoRowView(item: item, store: store)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 3)
                }
            }
            .padding(.vertical, 6)
        }
        .overlay {
            if filteredTodos.isEmpty {
                Text(store.todos.isEmpty ? "No todos yet" : "No todos in this tag")
                    .foregroundStyle(.tertiary)
                    .font(.subheadline)
            }
        }
    }

    // MARK: Add input

    private var addInput: some View {
        HStack(spacing: 8) {
            Image(systemName: "plus")
                .foregroundStyle(.tertiary)
                .font(.system(size: 12))

            TextField("Add todo…", text: $newText)
                .textFieldStyle(.plain)
                .focused($inputFocused)
                .onSubmit { submitNewTodo() }

            if !store.allTags.isEmpty || !newTag.isEmpty {
                Menu {
                    Button("No tag") { newTag = "" }
                    Divider()
                    ForEach(store.allTags, id: \.self) { tag in
                        Button(tag) { newTag = tag }
                    }
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "tag")
                            .font(.system(size: 10))
                        if !newTag.isEmpty {
                            Text(newTag)
                                .font(.caption2)
                        }
                    }
                    .foregroundStyle(newTag.isEmpty ? .tertiary : .secondary)
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
            }

            if !newText.isEmpty {
                Button(action: submitNewTodo) {
                    Image(systemName: "return")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
    }

    private func submitNewTodo() {
        let trimmed = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let tag = newTag.isEmpty ? selectedTag : newTag
        store.add(trimmed, tag: tag?.isEmpty == false ? tag : nil)
        newText = ""
        inputFocused = true
    }
}

// MARK: GlassModifier

private struct GlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            content
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 14))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

// MARK: TagChip

private struct TagChip: View {
    let label: String
    let selected: Bool
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.weight(selected ? .semibold : .regular))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    selected
                        ? Color.accentColor.opacity(0.2)
                        : Color.primary.opacity(hovered ? 0.08 : 0.05),
                    in: Capsule()
                )
                .foregroundStyle(selected ? Color.accentColor : Color.secondary)
        }
        .buttonStyle(.plain)
        .onHover { hovered = $0 }
    }
}
