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
        .background(.ultraThinMaterial)
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
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(store.todos) { item in
                    TodoRowView(item: item, store: store)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 2)
                }
            }
            .padding(.vertical, 4)
        }
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

    private func submitNewTodo() {
        let trimmed = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.add(trimmed)
        newText = ""
        inputFocused = true
    }
}
