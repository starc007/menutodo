import SwiftUI

struct PopoverView: View {
    let store: TodoStore
    @State private var newText = ""
    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            todoList
            Divider()
            addInput
        }
        .frame(width: 320, height: 400)
        .background(glassBackground)
    }

    private var header: some View {
        HStack {
            Text("Todos")
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
            if store.todos.contains(where: { $0.done }) {
                Button("Clear done") {
                    store.clearCompleted()
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var todoList: some View {
        List {
            ForEach(store.todos) { item in
                TodoRowView(item: item, store: store)
                    .listRowInsets(EdgeInsets(top: 2, leading: 12, bottom: 2, trailing: 12))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .overlay {
            if store.todos.isEmpty {
                Text("No todos yet")
                    .foregroundStyle(.tertiary)
                    .font(.subheadline)
            }
        }
    }

    private var addInput: some View {
        HStack(spacing: 8) {
            Image(systemName: "plus")
                .foregroundStyle(.secondary)
                .font(.system(size: 13))

            TextField("Add todo…", text: $newText)
                .textFieldStyle(.plain)
                .focused($inputFocused)
                .onSubmit { submitNewTodo() }

            if !newText.isEmpty {
                Button(action: submitNewTodo) {
                    Image(systemName: "return")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private var glassBackground: some View {
        if #available(macOS 26, *) {
            Rectangle()
                .glassEffect()
        } else {
            Rectangle()
                .fill(.ultraThinMaterial)
        }
    }

    private func submitNewTodo() {
        let trimmed = newText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        store.add(trimmed)
        newText = ""
    }
}
